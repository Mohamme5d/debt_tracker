namespace Ijari.Api.DTOs;

public record ExpenseRequest(string Description, decimal Amount, DateOnly ExpenseDate, string? Category, int Month, int Year, string? Notes);

public record ExpenseResponse(Guid Id, string Description, decimal Amount, DateOnly ExpenseDate, string? Category, int Month, int Year, string? Notes, string Status, DateTime CreatedAt);
