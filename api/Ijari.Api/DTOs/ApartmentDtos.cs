namespace Ijari.Api.DTOs;

public record ApartmentRequest(string Name, string? Address, string? Description, string? Notes);

public record ApartmentResponse(Guid Id, string Name, string? Address, string? Description, string? Notes, DateTime CreatedAt);
