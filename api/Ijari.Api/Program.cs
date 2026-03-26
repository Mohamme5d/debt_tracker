using System.Text;
using Ijari.Api.Middleware;
using Ijari.Core.Entities;
using Ijari.Core.Enums;
using Ijari.Core.Interfaces;
using Ijari.Infrastructure.Data;
using Ijari.Infrastructure.Repositories;
using Ijari.Infrastructure.Services;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;

var builder = WebApplication.CreateBuilder(args);

// ── Database provider ─────────────────────────────────────────────────────────
// Set  Database:Provider  to  PostgreSQL | MySQL | SqlServer  in config/env.
// The matching named connection string is used automatically.
var dbProvider = (builder.Configuration["Database:Provider"] ?? "PostgreSQL").Trim();
var connStr = builder.Configuration.GetConnectionString(dbProvider)
           ?? builder.Configuration.GetConnectionString("Default")!;

builder.Services.AddDbContext<AppDbContext>((sp, opts) =>
{
    switch (dbProvider.ToLowerInvariant())
    {
        case "mysql":
            // Use a static server version — AutoDetect requires a live connection
            // at DI registration time which can fail if the container isn't ready yet.
            opts.UseMySql(connStr, new MySqlServerVersion(new Version(8, 0, 0)));
            break;
        case "sqlserver":
            opts.UseSqlServer(connStr);
            break;
        default: // postgresql
            opts.UseNpgsql(connStr);
            break;
    }
});

// ── Core services ─────────────────────────────────────────────────────────────
builder.Services.AddHttpContextAccessor();
builder.Services.AddScoped<ICurrentTenant, CurrentTenantService>();
builder.Services.AddScoped<ITokenService, TokenService>();
builder.Services.AddScoped<IEmailService, EmailService>();
builder.Services.AddScoped<IApprovalService, ApprovalService>();
builder.Services.AddScoped(typeof(IRepository<>), typeof(GenericRepository<>));

// ── JWT Authentication ────────────────────────────────────────────────────────
var jwtSecret = builder.Configuration["Jwt:Secret"]!;
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(opts =>
    {
        opts.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuerSigningKey = true,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtSecret)),
            ValidateIssuer = true,
            ValidIssuer = builder.Configuration["Jwt:Issuer"],
            ValidateAudience = true,
            ValidAudience = builder.Configuration["Jwt:Audience"],
            ClockSkew = TimeSpan.Zero
        };
    });

builder.Services.AddAuthorization();
builder.Services.AddControllers();

var corsOrigins = builder.Configuration.GetSection("Cors:Origins").Get<string[]>() ?? [];
builder.Services.AddCors(opts =>
    opts.AddDefaultPolicy(p =>
    {
        if (corsOrigins.Length == 0 || corsOrigins.Contains("*"))
            p.AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader();
        else
            p.WithOrigins(corsOrigins).AllowAnyMethod().AllowAnyHeader().AllowCredentials();
    }));

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "Ijari API", Version = "v1" });
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        In = ParameterLocation.Header,
        Description = "Enter: Bearer {token}",
        Name = "Authorization",
        Type = SecuritySchemeType.ApiKey,
        Scheme = "Bearer"
    });
    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme { Reference = new OpenApiReference { Type = ReferenceType.SecurityScheme, Id = "Bearer" } },
            []
        }
    });
});

var app = builder.Build();

// ── Auto-migrate + seed ───────────────────────────────────────────────────────
// Retries up to 10 times with 3-second delays so the API gracefully waits for
// the database container to become ready (MySQL and SQL Server start slower).
await MigrateAndSeedAsync(app);

app.UseMiddleware<ExceptionMiddleware>();
app.UseCors();
app.UseSwagger();
app.UseSwaggerUI();
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();
app.Run();

// ─────────────────────────────────────────────────────────────────────────────
static async Task MigrateAndSeedAsync(WebApplication app)
{
    const int maxRetries = 10;
    const int delaySeconds = 3;

    using var scope = app.Services.CreateScope();
    var db     = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    var config = scope.ServiceProvider.GetRequiredService<IConfiguration>();
    var logger = scope.ServiceProvider.GetRequiredService<ILogger<Program>>();
    var provider = (config["Database:Provider"] ?? "PostgreSQL").Trim();

    logger.LogInformation("Database provider: {Provider}", provider);

    for (int attempt = 1; attempt <= maxRetries; attempt++)
    {
        try
        {
            logger.LogInformation("Applying migrations (attempt {Attempt}/{Max})…", attempt, maxRetries);
            await db.Database.MigrateAsync();
            logger.LogInformation("Migrations applied successfully.");
            break;
        }
        catch (Exception ex) when (attempt < maxRetries)
        {
            logger.LogWarning("Migration failed: {Message}. Retrying in {Delay}s…", ex.Message, delaySeconds);
            await Task.Delay(TimeSpan.FromSeconds(delaySeconds));
        }
    }

    // Seed SuperAdmin + platform tenant if not present
    if (!db.Users.IgnoreQueryFilters().Any(u => u.Role == UserRole.SuperAdmin))
    {
        var adminEmail    = config["Admin:Email"]    ?? "admin@ijari.app";
        var adminPassword = config["Admin:Password"] ?? "Admin@12345";
        var platformId    = new Guid("00000000-0000-0000-0000-000000000001");

        if (!db.Tenants.Any(t => t.Id == platformId))
        {
            db.Tenants.Add(new Tenant
            {
                Id        = platformId,
                Name      = "Ijari Platform",
                Email     = "platform@ijari.app",
                Plan      = "platform",
                IsActive  = true,
                CreatedAt = DateTime.UtcNow
            });
            await db.SaveChangesAsync();
        }

        db.Users.Add(new User
        {
            TenantId     = platformId,
            Name         = "Super Admin",
            Email        = adminEmail,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(adminPassword),
            Role         = UserRole.SuperAdmin,
            IsActive     = true,
            CreatedAt    = DateTime.UtcNow
        });
        await db.SaveChangesAsync();

        logger.LogInformation("Super admin seeded: {Email}", adminEmail);
    }
}
