using Ijari.Core.Enums;

namespace Ijari.Core.Entities;

public class ApprovalRequest : TenantEntity
{
    public EntityType EntityType { get; set; }
    public Guid EntityId { get; set; }
    public ApprovalAction Action { get; set; }
    public string? PayloadJson { get; set; }
    public ApprovalStatus Status { get; set; } = ApprovalStatus.Pending;
    public Guid SubmittedById { get; set; }
    public User SubmittedBy { get; set; } = null!;
    public Guid? ReviewedById { get; set; }
    public User? ReviewedBy { get; set; }
    public string? ReviewNotes { get; set; }
    public DateTime? ReviewedAt { get; set; }
}
