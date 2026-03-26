namespace Ijari.Core.Entities;

public class ApartmentAssignment : TenantEntity
{
    public Guid EmployeeId { get; set; }
    public Guid ApartmentId { get; set; }

    public User Employee { get; set; } = null!;
    public Apartment Apartment { get; set; } = null!;
}
