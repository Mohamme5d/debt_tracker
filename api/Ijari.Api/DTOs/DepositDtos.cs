namespace Ijari.Api.DTOs;

public record DepositRequest(int DepositMonth, int DepositYear, decimal Amount, string? Notes);

public record DepositResponse(Guid Id, int DepositMonth, int DepositYear, decimal Amount, string? Notes, string Status, DateTime CreatedAt);
