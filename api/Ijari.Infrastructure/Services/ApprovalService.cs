using Ijari.Core.Entities;
using Ijari.Core.Enums;
using Ijari.Core.Interfaces;
using Ijari.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace Ijari.Infrastructure.Services;

public class ApprovalService : IApprovalService
{
    private readonly AppDbContext _context;
    private readonly ICurrentTenant _currentTenant;
    private readonly IEmailService _emailService;

    public ApprovalService(AppDbContext context, ICurrentTenant currentTenant, IEmailService emailService)
    {
        _context = context;
        _currentTenant = currentTenant;
        _emailService = emailService;
    }

    public async Task CreateApprovalRequestAsync(EntityType entityType, Guid entityId, ApprovalAction action, Guid submittedById, string? payloadJson = null)
    {
        var request = new ApprovalRequest
        {
            TenantId = _currentTenant.Id,
            EntityType = entityType,
            EntityId = entityId,
            Action = action,
            SubmittedById = submittedById,
            PayloadJson = payloadJson,
            Status = ApprovalStatus.Pending
        };
        _context.ApprovalRequests.Add(request);

        // Notify owner(s)
        var owners = await _context.Users.IgnoreQueryFilters()
            .Where(u => u.TenantId == _currentTenant.Id && u.Role == UserRole.Owner && u.IsActive)
            .ToListAsync();

        var submitter = await _context.Users.IgnoreQueryFilters().FirstOrDefaultAsync(u => u.Id == submittedById);

        foreach (var owner in owners)
        {
            var notification = new Notification
            {
                TenantId = _currentTenant.Id,
                UserId = owner.Id,
                Title = "New Approval Request",
                Body = $"{submitter?.Name ?? "An employee"} submitted a {action} request for {entityType}.",
                EntityType = entityType,
                EntityId = entityId
            };
            _context.Notifications.Add(notification);

            try
            {
                await _emailService.SendAsync(owner.Email, owner.Name,
                    "New Approval Request - Ijari",
                    $"<p>Hello {owner.Name},</p><p>{submitter?.Name ?? "An employee"} submitted a <b>{action}</b> request for <b>{entityType}</b>. Please log in to review it.</p>");
            }
            catch { /* email failure is non-critical */ }
        }

        await _context.SaveChangesAsync();
    }

    public async Task ApproveAsync(Guid approvalId, Guid reviewerId, string? notes = null)
    {
        var request = await _context.ApprovalRequests.IgnoreQueryFilters()
            .FirstOrDefaultAsync(r => r.Id == approvalId) ?? throw new KeyNotFoundException("Approval not found");

        request.Status = ApprovalStatus.Approved;
        request.ReviewedById = reviewerId;
        request.ReviewNotes = notes;
        request.ReviewedAt = DateTime.UtcNow;

        await UpdateEntityStatusAsync(request.EntityType, request.EntityId, RecordStatus.Approved, reviewerId);
        await NotifySubmitterAsync(request, "approved");
        await _context.SaveChangesAsync();
    }

    public async Task RejectAsync(Guid approvalId, Guid reviewerId, string? notes = null)
    {
        var request = await _context.ApprovalRequests.IgnoreQueryFilters()
            .FirstOrDefaultAsync(r => r.Id == approvalId) ?? throw new KeyNotFoundException("Approval not found");

        request.Status = ApprovalStatus.Rejected;
        request.ReviewedById = reviewerId;
        request.ReviewNotes = notes;
        request.ReviewedAt = DateTime.UtcNow;

        await UpdateEntityStatusAsync(request.EntityType, request.EntityId, RecordStatus.Rejected, reviewerId);
        await NotifySubmitterAsync(request, "rejected");
        await _context.SaveChangesAsync();
    }

    private async Task UpdateEntityStatusAsync(EntityType type, Guid entityId, RecordStatus status, Guid reviewerId)
    {
        switch (type)
        {
            case EntityType.Renter:
                var renter = await _context.Renters.IgnoreQueryFilters().FirstOrDefaultAsync(e => e.Id == entityId);
                if (renter != null) { renter.Status = status; renter.ApprovedById = reviewerId; }
                break;
            case EntityType.RentPayment:
                var payment = await _context.RentPayments.IgnoreQueryFilters().FirstOrDefaultAsync(e => e.Id == entityId);
                if (payment != null) { payment.Status = status; payment.ApprovedById = reviewerId; }
                break;
            case EntityType.Expense:
                var expense = await _context.Expenses.IgnoreQueryFilters().FirstOrDefaultAsync(e => e.Id == entityId);
                if (expense != null) { expense.Status = status; expense.ApprovedById = reviewerId; }
                break;
            case EntityType.MonthlyDeposit:
                var deposit = await _context.MonthlyDeposits.IgnoreQueryFilters().FirstOrDefaultAsync(e => e.Id == entityId);
                if (deposit != null) { deposit.Status = status; deposit.ApprovedById = reviewerId; }
                break;
        }
    }

    private async Task NotifySubmitterAsync(ApprovalRequest request, string action)
    {
        var submitter = await _context.Users.IgnoreQueryFilters().FirstOrDefaultAsync(u => u.Id == request.SubmittedById);
        if (submitter == null) return;

        var notification = new Notification
        {
            TenantId = request.TenantId,
            UserId = submitter.Id,
            Title = $"Request {action}",
            Body = $"Your {request.Action} request for {request.EntityType} has been {action}.",
            EntityType = request.EntityType,
            EntityId = request.EntityId
        };
        _context.Notifications.Add(notification);

        try
        {
            await _emailService.SendAsync(submitter.Email, submitter.Name,
                $"Your request was {action} - Ijari",
                $"<p>Hello {submitter.Name},</p><p>Your <b>{request.Action}</b> request for <b>{request.EntityType}</b> has been <b>{action}</b>.</p>");
        }
        catch { /* non-critical */ }
    }
}
