using Ijari.Core.Enums;

namespace Ijari.Core.Entities;

public class RentPayment : TenantEntity
{
    public Guid? ContractId { get; set; }
    public RentContract? Contract { get; set; }
    public Guid? RenterId { get; set; }
    public Renter? Renter { get; set; }
    public Guid ApartmentId { get; set; }
    public Apartment Apartment { get; set; } = null!;
    public int PaymentMonth { get; set; }
    public int PaymentYear { get; set; }
    public decimal RentAmount { get; set; }
    public decimal OutstandingBefore { get; set; }
    public decimal AmountPaid { get; set; }
    public decimal OutstandingAfter { get; set; }
    public bool IsVacant { get; set; } = false;
    public string? Notes { get; set; }
    public RecordStatus Status { get; set; } = RecordStatus.Approved;
    public Guid? SubmittedById { get; set; }
    public User? SubmittedBy { get; set; }
    public Guid? ApprovedById { get; set; }
    public User? ApprovedBy { get; set; }
}
