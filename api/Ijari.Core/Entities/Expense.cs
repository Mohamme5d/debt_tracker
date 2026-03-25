using Ijari.Core.Enums;

namespace Ijari.Core.Entities;

public class Expense : TenantEntity
{
    public string Description { get; set; } = string.Empty;
    public decimal Amount { get; set; }
    public DateOnly ExpenseDate { get; set; }
    public string? Category { get; set; }
    public int Month { get; set; }
    public int Year { get; set; }
    public string? Notes { get; set; }
    public RecordStatus Status { get; set; } = RecordStatus.Approved;
    public Guid? SubmittedById { get; set; }
    public User? SubmittedBy { get; set; }
    public Guid? ApprovedById { get; set; }
    public User? ApprovedBy { get; set; }
}
