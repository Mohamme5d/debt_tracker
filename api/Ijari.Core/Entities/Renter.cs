using Ijari.Core.Enums;

namespace Ijari.Core.Entities;

public class Renter : TenantEntity
{
    public Guid ApartmentId { get; set; }
    public Apartment Apartment { get; set; } = null!;
    public string Name { get; set; } = string.Empty;
    public string? Phone { get; set; }
    public string? Email { get; set; }
    public decimal MonthlyRent { get; set; }
    public DateOnly StartDate { get; set; }
    public bool IsActive { get; set; } = true;
    public string? Notes { get; set; }
    public RecordStatus Status { get; set; } = RecordStatus.Approved;
    public Guid? SubmittedById { get; set; }
    public User? SubmittedBy { get; set; }
    public Guid? ApprovedById { get; set; }
    public User? ApprovedBy { get; set; }
}
