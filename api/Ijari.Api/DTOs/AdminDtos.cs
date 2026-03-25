namespace Ijari.Api.DTOs;

public record PlatformStatsDto(
    int TotalTenants,
    int ActiveTenants,
    int InactiveTenants,
    int TotalUsers,
    int TotalApartments,
    int TotalActiveRenters,
    int NewTenantsThisMonth
);

public record AdminTenantListItemDto(
    Guid Id,
    string Name,
    string Email,
    string Plan,
    bool IsActive,
    DateTime CreatedAt,
    int UserCount,
    int ApartmentCount,
    int ActiveRenterCount
);

public record AdminTenantDetailDto(
    Guid Id,
    string Name,
    string Email,
    string Plan,
    bool IsActive,
    DateTime CreatedAt,
    List<AdminUserDto> Users,
    int ApartmentCount,
    int ActiveRenterCount,
    int TotalPayments
);

public record AdminUserDto(
    Guid Id,
    Guid? TenantId,
    string TenantName,
    string Name,
    string Email,
    string Role,
    string? Phone,
    bool IsActive,
    DateTime CreatedAt
);

public record SetTenantActiveRequest(bool IsActive);

public record SetUserActiveRequest(bool IsActive);

public record ResetPasswordRequest(string NewPassword);
