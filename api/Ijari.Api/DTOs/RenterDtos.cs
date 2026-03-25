namespace Ijari.Api.DTOs;

public record RenterRequest(Guid ApartmentId, string Name, string? Phone, string? Email,
    decimal MonthlyRent, DateOnly StartDate, bool IsActive, string? Notes);

public record RenterResponse(Guid Id, Guid ApartmentId, string ApartmentName, string Name, string? Phone,
    string? Email, decimal MonthlyRent, DateOnly StartDate, bool IsActive, string? Notes,
    string Status, DateTime CreatedAt);
