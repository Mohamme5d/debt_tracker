namespace Ijari.Api.DTOs;

public record RentPaymentRequest(
    Guid? ContractId, Guid? ApartmentId, int PaymentMonth, int PaymentYear,
    decimal RentAmount, decimal OutstandingBefore, decimal AmountPaid,
    bool IsVacant, string? Notes);

public record GenerateMonthRequest(int Month, int Year);

public record RentPaymentResponse(
    Guid Id, Guid? ContractId, Guid? RenterId, string? RenterName, Guid ApartmentId, string ApartmentName,
    int PaymentMonth, int PaymentYear, decimal RentAmount, decimal OutstandingBefore,
    decimal AmountPaid, decimal OutstandingAfter, bool IsVacant, string? Notes,
    string Status, DateTime CreatedAt);

public record PagedResult<T>(IEnumerable<T> Items, int TotalCount, int Page, int PageSize);

