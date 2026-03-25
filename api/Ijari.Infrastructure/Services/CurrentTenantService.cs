using System.Security.Claims;
using Ijari.Core.Interfaces;
using Microsoft.AspNetCore.Http;

namespace Ijari.Infrastructure.Services;

public class CurrentTenantService : ICurrentTenant
{
    private readonly IHttpContextAccessor _httpContextAccessor;

    public CurrentTenantService(IHttpContextAccessor httpContextAccessor)
    {
        _httpContextAccessor = httpContextAccessor;
    }

    private ClaimsPrincipal? User => _httpContextAccessor.HttpContext?.User;

    public Guid Id
    {
        get
        {
            var claim = User?.FindFirst("tenantId")?.Value;
            return claim != null ? Guid.Parse(claim) : Guid.Empty;
        }
    }

    public Guid UserId
    {
        get
        {
            var claim = User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            return claim != null ? Guid.Parse(claim) : Guid.Empty;
        }
    }

    public string Role => User?.FindFirst(ClaimTypes.Role)?.Value ?? string.Empty;

    public string Email => User?.FindFirst(ClaimTypes.Email)?.Value ?? string.Empty;

    public bool IsOwner => Role == "Owner";
    public bool IsSuperAdmin => Role == "SuperAdmin";
}
