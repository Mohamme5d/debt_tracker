using Ijari.Core.Enums;

namespace Ijari.Core.Entities;

public class MonthlyDeposit : TenantEntity
{
    public int DepositMonth { get; set; }
    public int DepositYear { get; set; }
    public decimal Amount { get; set; }
    public string? Notes { get; set; }
    public RecordStatus Status { get; set; } = RecordStatus.Approved;
    public Guid? SubmittedById { get; set; }
    public User? SubmittedBy { get; set; }
    public Guid? ApprovedById { get; set; }
    public User? ApprovedBy { get; set; }
}
