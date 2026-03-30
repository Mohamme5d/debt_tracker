namespace Ijari.Api.DTOs;

public record RentContractRequest(
    Guid RenterId, Guid ApartmentId, decimal MonthlyRent,
    DateOnly StartDate, DateOnly? EndDate, string? Notes);

public record RentContractResponse(
    Guid Id, Guid RenterId, string RenterName, Guid ApartmentId, string ApartmentName,
    decimal MonthlyRent, DateOnly StartDate, DateOnly? EndDate, bool IsActive,
    string? Notes, string Status, DateTime CreatedAt);
