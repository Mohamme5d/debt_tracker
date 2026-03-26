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
[Route("api/payments")]
[Authorize]
public class PaymentsController : ControllerBase
{
    private readonly AppDbContext _context;
    private readonly ICurrentTenant _tenant;
    private readonly IApprovalService _approvals;

    public PaymentsController(AppDbContext context, ICurrentTenant tenant, IApprovalService approvals)
    {
        _context = context;
        _tenant = tenant;
        _approvals = approvals;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<RentPaymentResponse>>> GetAll([FromQuery] int? month, [FromQuery] int? year)
    {
        var query = _context.RentPayments.Include(p => p.Apartment).Include(p => p.Renter).AsQueryable();
        if (month.HasValue) query = query.Where(p => p.PaymentMonth == month);
        if (year.HasValue) query = query.Where(p => p.PaymentYear == year);
        if (!_tenant.IsOwner)
        {
            var assigned = _context.ApartmentAssignments
                .Where(a => a.EmployeeId == _tenant.UserId)
                .Select(a => a.ApartmentId);
            query = query.Where(p => assigned.Contains(p.ApartmentId) &&
                                     (p.Status == RecordStatus.Approved || p.SubmittedById == _tenant.UserId));
        }
        return Ok((await query.ToListAsync()).Select(Map));
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<RentPaymentResponse>> Get(Guid id)
    {
        var p = await _context.RentPayments.Include(x => x.Apartment).Include(x => x.Renter).FirstOrDefaultAsync(x => x.Id == id);
        if (p == null) return NotFound();
        return Ok(Map(p));
    }

    [HttpPost]
    public async Task<ActionResult<RentPaymentResponse>> Create(RentPaymentRequest req)
    {
        if (!_tenant.IsOwner)
        {
            var isAssigned = await _context.ApartmentAssignments
                .AnyAsync(a => a.EmployeeId == _tenant.UserId && a.ApartmentId == req.ApartmentId);
            if (!isAssigned) return Forbid();
        }

        var outstanding = req.OutstandingBefore + req.RentAmount - req.AmountPaid;
        var status = _tenant.IsOwner ? RecordStatus.Approved : RecordStatus.Draft;

        var p = new RentPayment
        {
            TenantId = _tenant.Id,
            RenterId = req.RenterId,
            ApartmentId = req.ApartmentId,
            PaymentMonth = req.PaymentMonth,
            PaymentYear = req.PaymentYear,
            RentAmount = req.RentAmount,
            OutstandingBefore = req.OutstandingBefore,
            AmountPaid = req.AmountPaid,
            OutstandingAfter = outstanding,
            IsVacant = req.IsVacant,
            Notes = req.Notes,
            Status = status,
            SubmittedById = _tenant.UserId
        };
        _context.RentPayments.Add(p);
        await _context.SaveChangesAsync();

        if (!_tenant.IsOwner)
            await _approvals.CreateApprovalRequestAsync(EntityType.RentPayment, p.Id, ApprovalAction.Create, _tenant.UserId);

        var result = await _context.RentPayments.Include(x => x.Apartment).Include(x => x.Renter).FirstAsync(x => x.Id == p.Id);
        return CreatedAtAction(nameof(Get), new { id = p.Id }, Map(result));
    }

    [HttpPost("generate-month")]
    [Authorize(Roles = "Owner")]
    public async Task<ActionResult<IEnumerable<RentPaymentResponse>>> GenerateMonth(GenerateMonthRequest req)
    {
        var apartments = await _context.Apartments.ToListAsync();
        var activeRenters = await _context.Renters
            .Where(r => r.IsActive && r.Status == RecordStatus.Approved)
            .Include(r => r.Apartment)
            .ToListAsync();

        var existing = await _context.RentPayments
            .Where(p => p.PaymentMonth == req.Month && p.PaymentYear == req.Year)
            .Select(p => p.ApartmentId)
            .ToListAsync();

        var created = new List<RentPayment>();
        foreach (var apt in apartments)
        {
            if (existing.Contains(apt.Id)) continue;
            var renter = activeRenters.FirstOrDefault(r => r.ApartmentId == apt.Id);
            var p = new RentPayment
            {
                TenantId = _tenant.Id,
                ApartmentId = apt.Id,
                RenterId = renter?.Id,
                PaymentMonth = req.Month,
                PaymentYear = req.Year,
                RentAmount = renter?.MonthlyRent ?? 0,
                IsVacant = renter == null,
                Status = RecordStatus.Approved,
                SubmittedById = _tenant.UserId
            };
            _context.RentPayments.Add(p);
            created.Add(p);
        }

        await _context.SaveChangesAsync();

        var ids = created.Select(p => p.Id).ToList();
        var results = await _context.RentPayments.Include(x => x.Apartment).Include(x => x.Renter)
            .Where(p => ids.Contains(p.Id)).ToListAsync();

        return Ok(results.Select(Map));
    }

    [HttpPut("{id}")]
    public async Task<ActionResult<RentPaymentResponse>> Update(Guid id, RentPaymentRequest req)
    {
        var p = await _context.RentPayments.Include(x => x.Apartment).Include(x => x.Renter).FirstOrDefaultAsync(x => x.Id == id);
        if (p == null) return NotFound();
        if (!_tenant.IsOwner && p.SubmittedById != _tenant.UserId) return Forbid();

        p.AmountPaid = req.AmountPaid;
        p.OutstandingBefore = req.OutstandingBefore;
        p.OutstandingAfter = req.OutstandingBefore + req.RentAmount - req.AmountPaid;
        p.Notes = req.Notes;
        if (!_tenant.IsOwner) p.Status = RecordStatus.Draft;

        await _context.SaveChangesAsync();
        if (!_tenant.IsOwner)
            await _approvals.CreateApprovalRequestAsync(EntityType.RentPayment, p.Id, ApprovalAction.Update, _tenant.UserId);

        return Ok(Map(p));
    }

    [HttpDelete("{id}")]
    [Authorize(Roles = "Owner")]
    public async Task<IActionResult> Delete(Guid id)
    {
        var p = await _context.RentPayments.FindAsync(id);
        if (p == null) return NotFound();
        _context.RentPayments.Remove(p);
        await _context.SaveChangesAsync();
        return NoContent();
    }

    private static RentPaymentResponse Map(RentPayment p) =>
        new(p.Id, p.RenterId, p.Renter?.Name, p.ApartmentId, p.Apartment?.Name ?? "",
            p.PaymentMonth, p.PaymentYear, p.RentAmount, p.OutstandingBefore,
            p.AmountPaid, p.OutstandingAfter, p.IsVacant, p.Notes, p.Status.ToString(), p.CreatedAt);
}
