namespace Ijari.Api.DTOs;

public record InviteEmployeeRequest(string Name, string Email, string Password, string? Phone);

public record UpdateEmployeeRequest(string Name, string? Phone, bool IsActive);
