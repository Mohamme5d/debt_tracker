namespace Ijari.Api.DTOs;

public record DashboardStats(
    int TotalApartments,
    int ActiveRenters,
    decimal TotalCollectedThisMonth,
    decimal TotalOutstanding,
    decimal TotalExpensesThisMonth,
    int PendingApprovals,
    int UnreadNotifications
);

public record MonthlyReportResponse(
    int Month, int Year,
    decimal TotalRentCollected,
    decimal TotalOutstanding,
    decimal TotalExpenses,
    decimal TotalDeposit,
    decimal NetBalance,
    List<PaymentSummary> Payments,
    List<ExpenseSummary> Expenses
);

public record PaymentSummary(string ApartmentName, string? RenterName, decimal AmountPaid, decimal Outstanding);
public record ExpenseSummary(string Description, string? Category, decimal Amount);

public record CommissionReportResponse(
    int Month, int Year,
    decimal TotalRentCollected,
    decimal CommissionRate,
    decimal CommissionAmount
);

public record RenterApartmentReportRow(
    string ApartmentName,
    string? RenterName,
    int Month,
    int Year,
    decimal AmountPaid,
    decimal OutstandingAfter
);

public record RenterApartmentReportResponse(
    List<RenterApartmentReportRow> Rows,
    decimal TotalPaid,
    decimal TotalOutstanding
);

public record ApartmentSummary(string ApartmentName, string? RenterName, decimal TotalPaid, decimal TotalOutstanding);
public record ExpenseCategorySummary(string Category, decimal TotalAmount);

public record AllTimeReportResponse(
    decimal TotalRentCollected,
    decimal TotalOutstanding,
    decimal TotalExpenses,
    decimal TotalDeposits,
    decimal NetBalance,
    List<ApartmentSummary> Apartments,
    List<ExpenseCategorySummary> ExpenseCategories
);
