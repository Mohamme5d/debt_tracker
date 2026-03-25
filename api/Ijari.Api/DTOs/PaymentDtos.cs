namespace Ijari.Api.DTOs;

public record RentPaymentRequest(
    Guid? RenterId, Guid ApartmentId, int PaymentMonth, int PaymentYear,
    decimal RentAmount, decimal OutstandingBefore, decimal AmountPaid,
    bool IsVacant, string? Notes);

public record GenerateMonthRequest(int Month, int Year);

public record RentPaymentResponse(
    Guid Id, Guid? RenterId, string? RenterName, Guid ApartmentId, string ApartmentName,
    int PaymentMonth, int PaymentYear, decimal RentAmount, decimal OutstandingBefore,
    decimal AmountPaid, decimal OutstandingAfter, bool IsVacant, string? Notes,
    string Status, DateTime CreatedAt);
