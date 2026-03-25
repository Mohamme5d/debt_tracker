using Ijari.Api.DTOs;
using Ijari.Core.Entities;
using Ijari.Core.Enums;
using Ijari.Core.Interfaces;
using Ijari.Infrastructure.Data;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Ijari.Api.Controllers;

[ApiController]
[Route("api/deposits")]
[Authorize]
public class DepositsController : ControllerBase
{
    private readonly AppDbContext _context;
    private readonly ICurrentTenant _tenant;
    private readonly IApprovalService _approvals;

    public DepositsController(AppDbContext context, ICurrentTenant tenant, IApprovalService approvals)
    {
        _context = context;
        _tenant = tenant;
        _approvals = approvals;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<DepositResponse>>> GetAll()
    {
        var query = _context.MonthlyDeposits.AsQueryable();
        if (!_tenant.IsOwner)
            query = query.Where(d => d.Status == RecordStatus.Approved || d.SubmittedById == _tenant.UserId);
        return Ok((await query.ToListAsync()).Select(Map));
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<DepositResponse>> Get(Guid id)
    {
        var d = await _context.MonthlyDeposits.FindAsync(id);
        return d == null ? NotFound() : Ok(Map(d));
    }

    [HttpPost]
    public async Task<ActionResult<DepositResponse>> Create(DepositRequest req)
    {
        var d = new MonthlyDeposit
        {
            TenantId = _tenant.Id,
            DepositMonth = req.DepositMonth,
            DepositYear = req.DepositYear,
            Amount = req.Amount,
            Notes = req.Notes,
            Status = _tenant.IsOwner ? RecordStatus.Approved : RecordStatus.Draft,
            SubmittedById = _tenant.UserId
        };
        _context.MonthlyDeposits.Add(d);
        await _context.SaveChangesAsync();

        if (!_tenant.IsOwner)
            await _approvals.CreateApprovalRequestAsync(EntityType.MonthlyDeposit, d.Id, ApprovalAction.Create, _tenant.UserId);

        return CreatedAtAction(nameof(Get), new { id = d.Id }, Map(d));
    }

    [HttpPut("{id}")]
    public async Task<ActionResult<DepositResponse>> Update(Guid id, DepositRequest req)
    {
        var d = await _context.MonthlyDeposits.FindAsync(id);
        if (d == null) return NotFound();
        if (!_tenant.IsOwner && d.SubmittedById != _tenant.UserId) return Forbid();

        d.Amount = req.Amount;
        d.Notes = req.Notes;
        if (!_tenant.IsOwner) d.Status = RecordStatus.Draft;
        await _context.SaveChangesAsync();

        if (!_tenant.IsOwner)
            await _approvals.CreateApprovalRequestAsync(EntityType.MonthlyDeposit, d.Id, ApprovalAction.Update, _tenant.UserId);

        return Ok(Map(d));
    }

    [HttpDelete("{id}")]
    [Authorize(Roles = "Owner")]
    public async Task<IActionResult> Delete(Guid id)
    {
        var d = await _context.MonthlyDeposits.FindAsync(id);
        if (d == null) return NotFound();
        _context.MonthlyDeposits.Remove(d);
        await _context.SaveChangesAsync();
        return NoContent();
    }

    private static DepositResponse Map(MonthlyDeposit d) =>
        new(d.Id, d.DepositMonth, d.DepositYear, d.Amount, d.Notes, d.Status.ToString(), d.CreatedAt);
}
