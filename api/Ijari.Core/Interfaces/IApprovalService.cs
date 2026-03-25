using Ijari.Core.Entities;
using Ijari.Core.Enums;

namespace Ijari.Core.Interfaces;

public interface IApprovalService
{
    Task CreateApprovalRequestAsync(EntityType entityType, Guid entityId, ApprovalAction action, Guid submittedById, string? payloadJson = null);
    Task ApproveAsync(Guid approvalId, Guid reviewerId, string? notes = null);
    Task RejectAsync(Guid approvalId, Guid reviewerId, string? notes = null);
}
