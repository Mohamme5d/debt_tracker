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
    public async Task<ActionResult<PagedResult<RentPaymentResponse>>> GetAll(
        [FromQuery] int? month,
        [FromQuery] int? year,
        [FromQuery] Guid? renterId,
        [FromQuery] Guid? apartmentId,
        [FromQuery] string? status,
        [FromQuery] string? sortBy,
        [FromQuery] string? sortDir,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 50)
    {
        var query = _context.RentPayments
            .Include(p => p.Apartment)
            .Include(p => p.Renter)
            .Include(p => p.Contract)
            .Where(p => p.TenantId == _tenant.Id)
            .AsQueryable();

        if (month.HasValue) query = query.Where(p => p.PaymentMonth == month);
        if (year.HasValue)  query = query.Where(p => p.PaymentYear == year);
        if (renterId.HasValue)    query = query.Where(p => p.RenterId == renterId);
        if (apartmentId.HasValue) query = query.Where(p => p.ApartmentId == apartmentId);
        if (!string.IsNullOrWhiteSpace(status) && Enum.TryParse<RecordStatus>(status, true, out var parsedStatus))
            query = query.Where(p => p.Status == parsedStatus);

        if (!_tenant.IsOwner)
            query = query.Where(p => p.Status == RecordStatus.Approved || p.SubmittedById == _tenant.UserId);

        // Sorting
        bool asc = !string.Equals(sortDir, "desc", StringComparison.OrdinalIgnoreCase);
        query = sortBy?.ToLower() switch
        {
            "rentername"    => asc ? query.OrderBy(p => p.Renter!.Name)      : query.OrderByDescending(p => p.Renter!.Name),
            "apartmentname" => asc ? query.OrderBy(p => p.Apartment.Name)    : query.OrderByDescending(p => p.Apartment.Name),
            "amountpaid"    => asc ? query.OrderBy(p => p.AmountPaid)        : query.OrderByDescending(p => p.AmountPaid),
            "status"        => asc ? query.OrderBy(p => p.Status)            : query.OrderByDescending(p => p.Status),
            _               => asc
                                ? query.OrderBy(p => p.PaymentYear).ThenBy(p => p.PaymentMonth)
                                : query.OrderByDescending(p => p.PaymentYear).ThenByDescending(p => p.PaymentMonth),
        };

        // Pagination
        pageSize = Math.Clamp(pageSize, 1, 200);
        page     = Math.Max(page, 1);
        var totalCount = await query.CountAsync();
        var items = await query.Skip((page - 1) * pageSize).Take(pageSize).ToListAsync();

        return Ok(new PagedResult<RentPaymentResponse>(items.Select(Map), totalCount, page, pageSize));
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<RentPaymentResponse>> Get(Guid id)
    {
        var p = await _context.RentPayments
            .Include(x => x.Apartment).Include(x => x.Renter).Include(x => x.Contract)
            .FirstOrDefaultAsync(x => x.Id == id);
        if (p == null) return NotFound();
        return Ok(Map(p));
    }

    [HttpPost]
    public async Task<ActionResult<RentPaymentResponse>> Create(RentPaymentRequest req)
    {
        Guid? renterId = null;
        Guid apartmentId;
        decimal rentAmount = req.RentAmount;

        if (req.ContractId.HasValue)
        {
            var contract = await _context.RentContracts.FirstOrDefaultAsync(c => c.Id == req.ContractId.Value);
            if (contract == null) return BadRequest("Contract not found.");
            renterId = contract.RenterId;
            apartmentId = contract.ApartmentId;
            if (rentAmount == 0) rentAmount = contract.MonthlyRent;
        }
        else
        {
            if (!req.ApartmentId.HasValue) return BadRequest("ApartmentId required for vacant payments.");
            apartmentId = req.ApartmentId.Value;
        }

        var outstanding = req.OutstandingBefore + rentAmount - req.AmountPaid;
        var status = _tenant.IsOwner ? RecordStatus.Approved : RecordStatus.Draft;

        var p = new RentPayment
        {
            TenantId = _tenant.Id,
            ContractId = req.ContractId,
            RenterId = renterId,
            ApartmentId = apartmentId,
            PaymentMonth = req.PaymentMonth,
            PaymentYear = req.PaymentYear,
            RentAmount = rentAmount,
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

        var result = await _context.RentPayments
            .Include(x => x.Apartment).Include(x => x.Renter).Include(x => x.Contract)
            .FirstAsync(x => x.Id == p.Id);
        return CreatedAtAction(nameof(Get), new { id = p.Id }, Map(result));
    }

    [HttpPost("generate-month")]
    [Authorize(Roles = "Owner")]
    public async Task<ActionResult<IEnumerable<RentPaymentResponse>>> GenerateMonth(GenerateMonthRequest req)
    {
        var apartments = await _context.Apartments.ToListAsync();
        var activeContracts = await _context.RentContracts
            .Where(c => c.IsActive && c.Status == RecordStatus.Approved)
            .Include(c => c.Renter)
            .ToListAsync();

        var existing = await _context.RentPayments
            .Where(p => p.PaymentMonth == req.Month && p.PaymentYear == req.Year)
            .Select(p => p.ApartmentId)
            .ToListAsync();

        var created = new List<RentPayment>();
        foreach (var contract in activeContracts)
        {
            if (existing.Contains(contract.ApartmentId)) continue;
            var p = new RentPayment
            {
                TenantId = _tenant.Id,
                ContractId = contract.Id,
                ApartmentId = contract.ApartmentId,
                RenterId = contract.RenterId,
                PaymentMonth = req.Month,
                PaymentYear = req.Year,
                RentAmount = contract.MonthlyRent,
                IsVacant = false,
                Status = RecordStatus.Approved,
                SubmittedById = _tenant.UserId
            };
            _context.RentPayments.Add(p);
            created.Add(p);
            existing.Add(contract.ApartmentId);
        }

        // vacant records for apartments without active contracts
        foreach (var apt in apartments)
        {
            if (existing.Contains(apt.Id)) continue;
            var p = new RentPayment
            {
                TenantId = _tenant.Id,
                ApartmentId = apt.Id,
                PaymentMonth = req.Month,
                PaymentYear = req.Year,
                IsVacant = true,
                Status = RecordStatus.Approved,
                SubmittedById = _tenant.UserId
            };
            _context.RentPayments.Add(p);
            created.Add(p);
        }

        await _context.SaveChangesAsync();

        var ids = created.Select(p => p.Id).ToList();
        var results = await _context.RentPayments
            .Include(x => x.Apartment).Include(x => x.Renter).Include(x => x.Contract)
            .Where(p => ids.Contains(p.Id)).ToListAsync();

        return Ok(results.Select(Map));
    }

    [HttpPut("{id}")]
    public async Task<ActionResult<RentPaymentResponse>> Update(Guid id, RentPaymentRequest req)
    {
        var p = await _context.RentPayments
            .Include(x => x.Apartment).Include(x => x.Renter).Include(x => x.Contract)
            .FirstOrDefaultAsync(x => x.Id == id);
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
        new(p.Id, p.ContractId, p.RenterId, p.Renter?.Name, p.ApartmentId, p.Apartment?.Name ?? "",
            p.PaymentMonth, p.PaymentYear, p.RentAmount, p.OutstandingBefore,
            p.AmountPaid, p.OutstandingAfter, p.IsVacant, p.Notes, p.Status.ToString(), p.CreatedAt);
}
