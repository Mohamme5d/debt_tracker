using Ijari.Core.Enums;

namespace Ijari.Core.Entities;

public class Notification : TenantEntity
{
    public Guid UserId { get; set; }
    public User User { get; set; } = null!;
    public string Title { get; set; } = string.Empty;
    public string Body { get; set; } = string.Empty;
    public bool IsRead { get; set; } = false;
    public EntityType? EntityType { get; set; }
    public Guid? EntityId { get; set; }
}
