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
[Route("api/renters")]
[Authorize]
public class RentersController : ControllerBase
{
    private readonly AppDbContext _context;
    private readonly ICurrentTenant _tenant;
    private readonly IApprovalService _approvals;

    public RentersController(AppDbContext context, ICurrentTenant tenant, IApprovalService approvals)
    {
        _context = context;
        _tenant = tenant;
        _approvals = approvals;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<RenterResponse>>> GetAll()
    {
        var query = _context.Renters.Include(r => r.Apartment).AsQueryable();

        if (!_tenant.IsOwner)
            query = query.Where(r => r.Status == RecordStatus.Approved || r.SubmittedById == _tenant.UserId);

        var list = await query.ToListAsync();
        return Ok(list.Select(Map));
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<RenterResponse>> Get(Guid id)
    {
        var r = await _context.Renters.Include(x => x.Apartment).FirstOrDefaultAsync(x => x.Id == id);
        if (r == null) return NotFound();
        if (!_tenant.IsOwner && r.Status != RecordStatus.Approved && r.SubmittedById != _tenant.UserId) return Forbid();
        return Ok(Map(r));
    }

    [HttpPost]
    public async Task<ActionResult<RenterResponse>> Create(RenterRequest req)
    {
        var status = _tenant.IsOwner ? RecordStatus.Approved : RecordStatus.Draft;
        var r = new Renter
        {
            TenantId = _tenant.Id,
            ApartmentId = req.ApartmentId,
            Name = req.Name,
            Phone = req.Phone,
            Email = req.Email,
            MonthlyRent = req.MonthlyRent,
            StartDate = req.StartDate,
            IsActive = req.IsActive,
            Notes = req.Notes,
            Status = status,
            SubmittedById = _tenant.UserId
        };
        _context.Renters.Add(r);
        await _context.SaveChangesAsync();

        if (!_tenant.IsOwner)
            await _approvals.CreateApprovalRequestAsync(EntityType.Renter, r.Id, ApprovalAction.Create, _tenant.UserId);

        var result = await _context.Renters.Include(x => x.Apartment).FirstAsync(x => x.Id == r.Id);
        return CreatedAtAction(nameof(Get), new { id = r.Id }, Map(result));
    }

    [HttpPut("{id}")]
    public async Task<ActionResult<RenterResponse>> Update(Guid id, RenterRequest req)
    {
        var r = await _context.Renters.Include(x => x.Apartment).FirstOrDefaultAsync(x => x.Id == id);
        if (r == null) return NotFound();
        if (!_tenant.IsOwner && r.SubmittedById != _tenant.UserId) return Forbid();

        r.ApartmentId = req.ApartmentId;
        r.Name = req.Name;
        r.Phone = req.Phone;
        r.Email = req.Email;
        r.MonthlyRent = req.MonthlyRent;
        r.StartDate = req.StartDate;
        r.IsActive = req.IsActive;
        r.Notes = req.Notes;

        if (!_tenant.IsOwner) r.Status = RecordStatus.Draft;
        await _context.SaveChangesAsync();

        if (!_tenant.IsOwner)
            await _approvals.CreateApprovalRequestAsync(EntityType.Renter, r.Id, ApprovalAction.Update, _tenant.UserId);

        return Ok(Map(r));
    }

    [HttpDelete("{id}")]
    [Authorize(Roles = "Owner")]
    public async Task<IActionResult> Delete(Guid id)
    {
        var r = await _context.Renters.FindAsync(id);
        if (r == null) return NotFound();
        _context.Renters.Remove(r);
        await _context.SaveChangesAsync();
        return NoContent();
    }

    private static RenterResponse Map(Renter r) =>
        new(r.Id, r.ApartmentId, r.Apartment?.Name ?? "", r.Name, r.Phone, r.Email,
            r.MonthlyRent, r.StartDate, r.IsActive, r.Notes, r.Status.ToString(), r.CreatedAt);
}
