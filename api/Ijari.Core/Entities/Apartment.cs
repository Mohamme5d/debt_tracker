namespace Ijari.Core.Entities;

public class Apartment : TenantEntity
{
    public string Name { get; set; } = string.Empty;
    public string? Address { get; set; }
    public string? Description { get; set; }
    public string? Notes { get; set; }

    public ICollection<RentPayment> Payments { get; set; } = [];
}
