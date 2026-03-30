namespace Ijari.Api.DTOs;

public record RenterRequest(string Name, string? Phone, string? Email, string? Notes);

public record RenterResponse(Guid Id, string Name, string? Phone, string? Email, string? Notes,
    string Status, DateTime CreatedAt);
