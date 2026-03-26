using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;
using Microsoft.Extensions.Configuration;

namespace Ijari.Infrastructure.Data;

/// <summary>
/// Design-time factories let you generate provider-specific migrations.
///
/// PostgreSQL (default):
///   dotnet ef migrations add MigrationName --project Ijari.Infrastructure --startup-project Ijari.Api
///
/// MySQL:
///   dotnet ef migrations add MigrationName --project Ijari.Infrastructure --startup-project Ijari.Api \
///     -- --provider mysql
///   (requires setting env: EF_PROVIDER=mysql  OR passing args)
///   Use MySqlDbContextFactory below by setting env var EF_PROVIDER=mysql before running the command.
///
/// SQL Server:
///   Set env var EF_PROVIDER=sqlserver before running dotnet ef migrations add.
/// </summary>

// ── PostgreSQL ────────────────────────────────────────────────────────────────
public class PostgreSqlDbContextFactory : IDesignTimeDbContextFactory<AppDbContext>
{
    public AppDbContext CreateDbContext(string[] args)
    {
        var opts = new DbContextOptionsBuilder<AppDbContext>();
        var connStr = DesignTimeHelper.GetConnStr(args, "postgresql",
            "Host=localhost;Port=5432;Database=ijari;Username=ijari;Password=ijari123");
        opts.UseNpgsql(connStr);
        return new AppDbContext(opts.Options);
    }
}

// ── MySQL ─────────────────────────────────────────────────────────────────────
public class MySqlDbContextFactory : IDesignTimeDbContextFactory<AppDbContext>
{
    public AppDbContext CreateDbContext(string[] args)
    {
        var opts = new DbContextOptionsBuilder<AppDbContext>();
        var connStr = DesignTimeHelper.GetConnStr(args, "mysql",
            "Server=localhost;Port=3306;Database=ijari;Uid=ijari;Pwd=ijari123;");
        opts.UseMySql(connStr, ServerVersion.AutoDetect(connStr));
        return new AppDbContext(opts.Options);
    }
}

// ── SQL Server ────────────────────────────────────────────────────────────────
public class SqlServerDbContextFactory : IDesignTimeDbContextFactory<AppDbContext>
{
    public AppDbContext CreateDbContext(string[] args)
    {
        var opts = new DbContextOptionsBuilder<AppDbContext>();
        var connStr = DesignTimeHelper.GetConnStr(args, "sqlserver",
            "Server=localhost,1433;Database=ijari;User Id=sa;Password=YourStrong@Passw0rd;TrustServerCertificate=True;");
        opts.UseSqlServer(connStr);
        return new AppDbContext(opts.Options);
    }
}

// ── Shared helper ─────────────────────────────────────────────────────────────
file static class DesignTimeHelper
{
    internal static string GetConnStr(string[] args, string providerKey, string fallback)
    {
        // 1. Check environment variable EF_PROVIDER / EF_CONNECTION_STRING
        var envConn = Environment.GetEnvironmentVariable("EF_CONNECTION_STRING");
        if (!string.IsNullOrWhiteSpace(envConn)) return envConn;

        // 2. Try appsettings.json
        var config = new ConfigurationBuilder()
            .SetBasePath(Path.Combine(Directory.GetCurrentDirectory(), "../Ijari.Api"))
            .AddJsonFile("appsettings.json", optional: true)
            .AddJsonFile("appsettings.Development.json", optional: true)
            .Build();

        return config.GetConnectionString(providerKey) ?? fallback;
    }
}
