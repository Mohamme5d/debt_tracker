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
[Route("api/expenses")]
[Authorize]
public class ExpensesController : ControllerBase
{
    private readonly AppDbContext _context;
    private readonly ICurrentTenant _tenant;
    private readonly IApprovalService _approvals;

    public ExpensesController(AppDbContext context, ICurrentTenant tenant, IApprovalService approvals)
    {
        _context = context;
        _tenant = tenant;
        _approvals = approvals;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<ExpenseResponse>>> GetAll([FromQuery] int? month, [FromQuery] int? year)
    {
        var query = _context.Expenses.AsQueryable();
        if (month.HasValue) query = query.Where(e => e.Month == month);
        if (year.HasValue) query = query.Where(e => e.Year == year);
        if (!_tenant.IsOwner)
            query = query.Where(e => e.Status == RecordStatus.Approved || e.SubmittedById == _tenant.UserId);
        return Ok((await query.ToListAsync()).Select(Map));
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<ExpenseResponse>> Get(Guid id)
    {
        var e = await _context.Expenses.FindAsync(id);
        return e == null ? NotFound() : Ok(Map(e));
    }

    [HttpPost]
    public async Task<ActionResult<ExpenseResponse>> Create(ExpenseRequest req)
    {
        var e = new Expense
        {
            TenantId = _tenant.Id,
            Description = req.Description,
            Amount = req.Amount,
            ExpenseDate = req.ExpenseDate,
            Category = req.Category,
            Month = req.Month,
            Year = req.Year,
            Notes = req.Notes,
            Status = _tenant.IsOwner ? RecordStatus.Approved : RecordStatus.Draft,
            SubmittedById = _tenant.UserId
        };
        _context.Expenses.Add(e);
        await _context.SaveChangesAsync();

        if (!_tenant.IsOwner)
            await _approvals.CreateApprovalRequestAsync(EntityType.Expense, e.Id, ApprovalAction.Create, _tenant.UserId);

        return CreatedAtAction(nameof(Get), new { id = e.Id }, Map(e));
    }

    [HttpPut("{id}")]
    public async Task<ActionResult<ExpenseResponse>> Update(Guid id, ExpenseRequest req)
    {
        var e = await _context.Expenses.FindAsync(id);
        if (e == null) return NotFound();
        if (!_tenant.IsOwner && e.SubmittedById != _tenant.UserId) return Forbid();

        e.Description = req.Description;
        e.Amount = req.Amount;
        e.ExpenseDate = req.ExpenseDate;
        e.Category = req.Category;
        e.Month = req.Month;
        e.Year = req.Year;
        e.Notes = req.Notes;
        if (!_tenant.IsOwner) e.Status = RecordStatus.Draft;
        await _context.SaveChangesAsync();

        if (!_tenant.IsOwner)
            await _approvals.CreateApprovalRequestAsync(EntityType.Expense, e.Id, ApprovalAction.Update, _tenant.UserId);

        return Ok(Map(e));
    }

    [HttpDelete("{id}")]
    [Authorize(Roles = "Owner")]
    public async Task<IActionResult> Delete(Guid id)
    {
        var e = await _context.Expenses.FindAsync(id);
        if (e == null) return NotFound();
        _context.Expenses.Remove(e);
        await _context.SaveChangesAsync();
        return NoContent();
    }

    private static ExpenseResponse Map(Expense e) =>
        new(e.Id, e.Description, e.Amount, e.ExpenseDate, e.Category, e.Month, e.Year, e.Notes, e.Status.ToString(), e.CreatedAt);
}
