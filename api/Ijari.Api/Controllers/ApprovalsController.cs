using Ijari.Api.DTOs;
using Ijari.Core.Enums;
using Ijari.Core.Interfaces;
using Ijari.Infrastructure.Data;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Ijari.Api.Controllers;

[ApiController]
[Route("api/approvals")]
[Authorize(Roles = "Owner")]
public class ApprovalsController : ControllerBase
{
    private readonly AppDbContext _context;
    private readonly ICurrentTenant _tenant;
    private readonly IApprovalService _approvals;

    public ApprovalsController(AppDbContext context, ICurrentTenant tenant, IApprovalService approvals)
    {
        _context = context;
        _tenant = tenant;
        _approvals = approvals;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<ApprovalRequestResponse>>> GetPending()
    {
        var list = await _context.ApprovalRequests
            .Include(r => r.SubmittedBy)
            .Include(r => r.ReviewedBy)
            .Where(r => r.Status == ApprovalStatus.Pending)
            .OrderByDescending(r => r.CreatedAt)
            .ToListAsync();

        return Ok(list.Select(r => new ApprovalRequestResponse(
            r.Id, r.EntityType.ToString(), r.EntityId, r.Action.ToString(), r.Status.ToString(),
            r.SubmittedBy.Name, r.SubmittedBy.Email,
            r.ReviewedBy?.Name, r.ReviewNotes, r.CreatedAt, r.ReviewedAt)));
    }

    [HttpGet("all")]
    public async Task<ActionResult<IEnumerable<ApprovalRequestResponse>>> GetAll()
    {
        var list = await _context.ApprovalRequests
            .Include(r => r.SubmittedBy)
            .Include(r => r.ReviewedBy)
            .OrderByDescending(r => r.CreatedAt)
            .ToListAsync();

        return Ok(list.Select(r => new ApprovalRequestResponse(
            r.Id, r.EntityType.ToString(), r.EntityId, r.Action.ToString(), r.Status.ToString(),
            r.SubmittedBy.Name, r.SubmittedBy.Email,
            r.ReviewedBy?.Name, r.ReviewNotes, r.CreatedAt, r.ReviewedAt)));
    }

    [HttpPut("{id}/approve")]
    public async Task<IActionResult> Approve(Guid id, ReviewRequest req)
    {
        await _approvals.ApproveAsync(id, _tenant.UserId, req.Notes);
        return NoContent();
    }

    [HttpPut("{id}/reject")]
    public async Task<IActionResult> Reject(Guid id, ReviewRequest req)
    {
        await _approvals.RejectAsync(id, _tenant.UserId, req.Notes);
        return NoContent();
    }
}
