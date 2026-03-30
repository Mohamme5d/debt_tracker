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
[Route("api/contracts")]
[Authorize]
public class RentContractsController : ControllerBase
{
    private readonly AppDbContext _context;
    private readonly ICurrentTenant _tenant;
    private readonly IApprovalService _approvals;

    public RentContractsController(AppDbContext context, ICurrentTenant tenant, IApprovalService approvals)
    {
        _context = context;
        _tenant = tenant;
        _approvals = approvals;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<RentContractResponse>>> GetAll()
    {
        var query = _context.RentContracts
            .Include(c => c.Renter)
            .Include(c => c.Apartment)
            .AsQueryable();

        if (!_tenant.IsOwner)
            query = query.Where(c => c.Status == RecordStatus.Approved || c.SubmittedById == _tenant.UserId);

        var list = await query.ToListAsync();
        return Ok(list.Select(Map));
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<RentContractResponse>> Get(Guid id)
    {
        var c = await _context.RentContracts
            .Include(x => x.Renter)
            .Include(x => x.Apartment)
            .FirstOrDefaultAsync(x => x.Id == id);
        if (c == null) return NotFound();
        if (!_tenant.IsOwner && c.Status != RecordStatus.Approved && c.SubmittedById != _tenant.UserId) return Forbid();
        return Ok(Map(c));
    }

    [HttpPost]
    public async Task<ActionResult<RentContractResponse>> Create(RentContractRequest req)
    {
        var status = _tenant.IsOwner ? RecordStatus.Approved : RecordStatus.Draft;
        var c = new RentContract
        {
            TenantId = _tenant.Id,
            RenterId = req.RenterId,
            ApartmentId = req.ApartmentId,
            MonthlyRent = req.MonthlyRent,
            StartDate = req.StartDate,
            EndDate = req.EndDate,
            IsActive = true,
            Notes = req.Notes,
            Status = status,
            SubmittedById = _tenant.UserId
        };
        _context.RentContracts.Add(c);
        await _context.SaveChangesAsync();

        if (!_tenant.IsOwner)
            await _approvals.CreateApprovalRequestAsync(EntityType.RentContract, c.Id, ApprovalAction.Create, _tenant.UserId);

        var result = await _context.RentContracts
            .Include(x => x.Renter).Include(x => x.Apartment)
            .FirstAsync(x => x.Id == c.Id);
        return CreatedAtAction(nameof(Get), new { id = c.Id }, Map(result));
    }

    [HttpPut("{id}")]
    public async Task<ActionResult<RentContractResponse>> Update(Guid id, RentContractRequest req)
    {
        var c = await _context.RentContracts
            .Include(x => x.Renter).Include(x => x.Apartment)
            .FirstOrDefaultAsync(x => x.Id == id);
        if (c == null) return NotFound();
        if (!_tenant.IsOwner && c.SubmittedById != _tenant.UserId) return Forbid();

        c.RenterId = req.RenterId;
        c.ApartmentId = req.ApartmentId;
        c.MonthlyRent = req.MonthlyRent;
        c.StartDate = req.StartDate;
        c.EndDate = req.EndDate;
        c.Notes = req.Notes;

        if (!_tenant.IsOwner) c.Status = RecordStatus.Draft;
        await _context.SaveChangesAsync();

        if (!_tenant.IsOwner)
            await _approvals.CreateApprovalRequestAsync(EntityType.RentContract, c.Id, ApprovalAction.Update, _tenant.UserId);

        var result = await _context.RentContracts
            .Include(x => x.Renter).Include(x => x.Apartment)
            .FirstAsync(x => x.Id == c.Id);
        return Ok(Map(result));
    }

    [HttpPatch("{id}/deactivate")]
    [Authorize(Roles = "Owner")]
    public async Task<IActionResult> Deactivate(Guid id)
    {
        var c = await _context.RentContracts.FindAsync(id);
        if (c == null) return NotFound();
        c.IsActive = false;
        await _context.SaveChangesAsync();
        return NoContent();
    }

    [HttpDelete("{id}")]
    [Authorize(Roles = "Owner")]
    public async Task<IActionResult> Delete(Guid id)
    {
        var c = await _context.RentContracts.FindAsync(id);
        if (c == null) return NotFound();
        _context.RentContracts.Remove(c);
        await _context.SaveChangesAsync();
        return NoContent();
    }

    private static RentContractResponse Map(RentContract c) =>
        new(c.Id, c.RenterId, c.Renter?.Name ?? "", c.ApartmentId, c.Apartment?.Name ?? "",
            c.MonthlyRent, c.StartDate, c.EndDate, c.IsActive, c.Notes, c.Status.ToString(), c.CreatedAt);
}
