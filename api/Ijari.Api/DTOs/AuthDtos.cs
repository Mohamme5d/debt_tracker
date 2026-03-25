namespace Ijari.Api.DTOs;

public record RegisterRequest(string TenantName, string Name, string Email, string Password, string? Phone);
public record LoginRequest(string Email, string Password);
public record RefreshRequest(string RefreshToken);

public record AuthResponse(string AccessToken, string RefreshToken, UserDto User);

public record UserDto(Guid Id, Guid TenantId, string Name, string Email, string Role, string? Phone, bool IsActive);
