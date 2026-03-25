using Ijari.Api.DTOs;
using Ijari.Core.Entities;
using Ijari.Core.Enums;
using Ijari.Core.Interfaces;
using Ijari.Infrastructure.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Ijari.Api.Controllers;

[ApiController]
[Route("api/auth")]
public class AuthController : ControllerBase
{
    private readonly AppDbContext _context;
    private readonly ITokenService _tokenService;

    public AuthController(AppDbContext context, ITokenService tokenService)
    {
        _context = context;
        _tokenService = tokenService;
    }

    [HttpPost("register")]
    public async Task<ActionResult<AuthResponse>> Register(RegisterRequest req)
    {
        if (await _context.Users.IgnoreQueryFilters().AnyAsync(u => u.Email == req.Email))
            return Conflict(new { message = "Email already registered" });

        var tenant = new Tenant { Name = req.TenantName, Email = req.Email };
        _context.Tenants.Add(tenant);

        var user = new User
        {
            TenantId = tenant.Id,
            Name = req.Name,
            Email = req.Email,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(req.Password),
            Role = UserRole.Owner,
            Phone = req.Phone
        };
        _context.Users.Add(user);

        var refreshToken = CreateRefreshToken(user.Id);
        _context.RefreshTokens.Add(refreshToken);

        await _context.SaveChangesAsync();

        var accessToken = _tokenService.GenerateAccessToken(user);
        return Ok(BuildAuthResponse(accessToken, refreshToken.Token, user));
    }

    [HttpPost("login")]
    public async Task<ActionResult<AuthResponse>> Login(LoginRequest req)
    {
        var user = await _context.Users.IgnoreQueryFilters()
            .FirstOrDefaultAsync(u => u.Email == req.Email && u.IsActive);

        if (user == null || !BCrypt.Net.BCrypt.Verify(req.Password, user.PasswordHash))
            return Unauthorized(new { message = "Invalid credentials" });

        var refreshToken = CreateRefreshToken(user.Id);
        _context.RefreshTokens.Add(refreshToken);
        await _context.SaveChangesAsync();

        return Ok(BuildAuthResponse(_tokenService.GenerateAccessToken(user), refreshToken.Token, user));
    }

    [HttpPost("refresh")]
    public async Task<ActionResult<AuthResponse>> Refresh(RefreshRequest req)
    {
        var stored = await _context.RefreshTokens.IgnoreQueryFilters()
            .Include(r => r.User)
            .FirstOrDefaultAsync(r => r.Token == req.RefreshToken && !r.IsRevoked && r.ExpiresAt > DateTime.UtcNow);

        if (stored == null) return Unauthorized(new { message = "Invalid or expired refresh token" });

        stored.IsRevoked = true;
        var newRefresh = CreateRefreshToken(stored.UserId);
        _context.RefreshTokens.Add(newRefresh);
        await _context.SaveChangesAsync();

        return Ok(BuildAuthResponse(_tokenService.GenerateAccessToken(stored.User), newRefresh.Token, stored.User));
    }

    [HttpPost("logout")]
    public async Task<IActionResult> Logout(RefreshRequest req)
    {
        var stored = await _context.RefreshTokens.IgnoreQueryFilters()
            .FirstOrDefaultAsync(r => r.Token == req.RefreshToken);

        if (stored != null)
        {
            stored.IsRevoked = true;
            await _context.SaveChangesAsync();
        }

        return NoContent();
    }

    private RefreshToken CreateRefreshToken(Guid userId) => new RefreshToken
    {
        UserId = userId,
        Token = _tokenService.GenerateRefreshToken(),
        ExpiresAt = DateTime.UtcNow.AddDays(7)
    };

    private static AuthResponse BuildAuthResponse(string access, string refresh, User user) =>
        new(access, refresh, new UserDto(user.Id, user.TenantId, user.Name, user.Email, user.Role.ToString(), user.Phone, user.IsActive));
}
