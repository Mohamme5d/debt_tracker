using Ijari.Api.DTOs;
using Ijari.Core.Enums;
using Ijari.Infrastructure.Data;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Ijari.Api.Controllers;

[ApiController]
[Route("api/admin")]
[Authorize(Roles = "SuperAdmin")]
public class AdminController : ControllerBase
{
    private readonly AppDbContext _db;
    private static readonly Guid PlatformTenantId = new("00000000-0000-0000-0000-000000000001");

    public AdminController(AppDbContext db)
    {
        _db = db;
    }

    // ── Platform Stats ────────────────────────────────────────────────────────

    [HttpGet("stats")]
    public async Task<PlatformStatsDto> GetStats()
    {
        var now = DateTime.UtcNow;
        var firstOfMonth = new DateTime(now.Year, now.Month, 1, 0, 0, 0, DateTimeKind.Utc);

        var tenants = await _db.Tenants.IgnoreQueryFilters()
            .Where(t => t.Id != PlatformTenantId).ToListAsync();
        var users = await _db.Users.IgnoreQueryFilters()
            .Where(u => u.Role != UserRole.SuperAdmin)
            .CountAsync();
        var apartments = await _db.Apartments.IgnoreQueryFilters().CountAsync();
        var activeRenters = await _db.RentContracts.IgnoreQueryFilters()
            .Where(c => c.IsActive && c.Status == RecordStatus.Approved)
            .CountAsync();
        var newThisMonth = tenants.Count(t => t.CreatedAt >= firstOfMonth);

        return new PlatformStatsDto(
            TotalTenants: tenants.Count,
            ActiveTenants: tenants.Count(t => t.IsActive),
            InactiveTenants: tenants.Count(t => !t.IsActive),
            TotalUsers: users,
            TotalApartments: apartments,
            TotalActiveRenters: activeRenters,
            NewTenantsThisMonth: newThisMonth
        );
    }

    // ── Tenants ───────────────────────────────────────────────────────────────

    [HttpGet("tenants")]
    public async Task<List<AdminTenantListItemDto>> GetTenants([FromQuery] string? search)
    {
        var query = _db.Tenants.IgnoreQueryFilters()
            .Where(t => t.Id != PlatformTenantId).AsQueryable();

        if (!string.IsNullOrWhiteSpace(search))
            query = query.Where(t => t.Name.Contains(search) || t.Email.Contains(search));

        var tenants = await query.OrderByDescending(t => t.CreatedAt).ToListAsync();

        var result = new List<AdminTenantListItemDto>();
        foreach (var t in tenants)
        {
            var userCount = await _db.Users.IgnoreQueryFilters()
                .CountAsync(u => u.TenantId == t.Id && u.Role != UserRole.SuperAdmin);
            var aptCount = await _db.Apartments.IgnoreQueryFilters()
                .CountAsync(a => a.TenantId == t.Id);
            var renterCount = await _db.RentContracts.IgnoreQueryFilters()
                .CountAsync(c => c.TenantId == t.Id && c.IsActive && c.Status == RecordStatus.Approved);

            result.Add(new AdminTenantListItemDto(
                t.Id, t.Name, t.Email, t.Plan, t.IsActive, t.CreatedAt,
                userCount, aptCount, renterCount));
        }

        return result;
    }

    [HttpGet("tenants/{id:guid}")]
    public async Task<ActionResult<AdminTenantDetailDto>> GetTenant(Guid id)
    {
        var tenant = await _db.Tenants.IgnoreQueryFilters()
            .FirstOrDefaultAsync(t => t.Id == id);
        if (tenant == null) return NotFound();

        var users = await _db.Users.IgnoreQueryFilters()
            .Where(u => u.TenantId == id && u.Role != UserRole.SuperAdmin)
            .OrderBy(u => u.Name)
            .ToListAsync();

        var aptCount = await _db.Apartments.IgnoreQueryFilters().CountAsync(a => a.TenantId == id);
        var renterCount = await _db.RentContracts.IgnoreQueryFilters()
            .CountAsync(c => c.TenantId == id && c.IsActive && c.Status == RecordStatus.Approved);
        var paymentCount = await _db.RentPayments.IgnoreQueryFilters().CountAsync(p => p.TenantId == id);

        return new AdminTenantDetailDto(
            tenant.Id, tenant.Name, tenant.Email, tenant.Plan, tenant.IsActive, tenant.CreatedAt,
            users.Select(u => new AdminUserDto(u.Id, u.TenantId, tenant.Name, u.Name, u.Email,
                u.Role.ToString(), u.Phone, u.IsActive, u.CreatedAt)).ToList(),
            aptCount, renterCount, paymentCount);
    }

    [HttpPut("tenants/{id:guid}/status")]
    public async Task<IActionResult> SetTenantStatus(Guid id, [FromBody] SetTenantActiveRequest req)
    {
        var tenant = await _db.Tenants.IgnoreQueryFilters()
            .FirstOrDefaultAsync(t => t.Id == id);
        if (tenant == null) return NotFound();

        tenant.IsActive = req.IsActive;
        await _db.SaveChangesAsync();
        return NoContent();
    }

    // ── Users ─────────────────────────────────────────────────────────────────

    [HttpGet("users")]
    public async Task<List<AdminUserDto>> GetUsers([FromQuery] string? search, [FromQuery] Guid? tenantId)
    {
        var query = _db.Users.IgnoreQueryFilters()
            .Include(u => u.Tenant)
            .Where(u => u.Role != UserRole.SuperAdmin)
            .AsQueryable();

        if (tenantId.HasValue)
            query = query.Where(u => u.TenantId == tenantId.Value);

        if (!string.IsNullOrWhiteSpace(search))
            query = query.Where(u => u.Name.Contains(search) || u.Email.Contains(search));

        var users = await query.OrderBy(u => u.Name).ToListAsync();

        return users.Select(u => new AdminUserDto(
            u.Id, u.TenantId, u.Tenant?.Name ?? "", u.Name, u.Email,
            u.Role.ToString(), u.Phone, u.IsActive, u.CreatedAt
        )).ToList();
    }

    [HttpPut("users/{id:guid}/status")]
    public async Task<IActionResult> SetUserStatus(Guid id, [FromBody] SetUserActiveRequest req)
    {
        var user = await _db.Users.IgnoreQueryFilters()
            .FirstOrDefaultAsync(u => u.Id == id && u.Role != UserRole.SuperAdmin);
        if (user == null) return NotFound();

        user.IsActive = req.IsActive;
        await _db.SaveChangesAsync();
        return NoContent();
    }

    [HttpPost("users/{id:guid}/reset-password")]
    public async Task<IActionResult> ResetPassword(Guid id, [FromBody] ResetPasswordRequest req)
    {
        if (string.IsNullOrWhiteSpace(req.NewPassword) || req.NewPassword.Length < 6)
            return BadRequest("Password must be at least 6 characters.");

        var user = await _db.Users.IgnoreQueryFilters()
            .FirstOrDefaultAsync(u => u.Id == id && u.Role != UserRole.SuperAdmin);
        if (user == null) return NotFound();

        user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(req.NewPassword);
        await _db.SaveChangesAsync();
        return NoContent();
    }
}
