using Ijari.Api.DTOs;
using Ijari.Core.Entities;
using Ijari.Core.Interfaces;
using Ijari.Infrastructure.Data;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Ijari.Api.Controllers;

[ApiController]
[Route("api/apartments")]
[Authorize]
public class ApartmentsController : ControllerBase
{
    private readonly AppDbContext _context;
    private readonly ICurrentTenant _tenant;

    public ApartmentsController(AppDbContext context, ICurrentTenant tenant)
    {
        _context = context;
        _tenant = tenant;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<ApartmentResponse>>> GetAll()
    {
        IQueryable<Apartment> query = _context.Apartments;
        if (!_tenant.IsOwner)
        {
            var assigned = _context.ApartmentAssignments
                .Where(a => a.EmployeeId == _tenant.UserId)
                .Select(a => a.ApartmentId);
            query = query.Where(a => assigned.Contains(a.Id));
        }
        return Ok((await query.ToListAsync()).Select(Map));
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<ApartmentResponse>> Get(Guid id)
    {
        var a = await _context.Apartments.FindAsync(id);
        return a == null ? NotFound() : Ok(Map(a));
    }

    [HttpPost]
    [Authorize(Roles = "Owner")]
    public async Task<ActionResult<ApartmentResponse>> Create(ApartmentRequest req)
    {
        var a = new Apartment
        {
            TenantId = _tenant.Id,
            Name = req.Name,
            Address = req.Address,
            Description = req.Description,
            Notes = req.Notes
        };
        _context.Apartments.Add(a);
        await _context.SaveChangesAsync();
        return CreatedAtAction(nameof(Get), new { id = a.Id }, Map(a));
    }

    [HttpPut("{id}")]
    [Authorize(Roles = "Owner")]
    public async Task<ActionResult<ApartmentResponse>> Update(Guid id, ApartmentRequest req)
    {
        var a = await _context.Apartments.FindAsync(id);
        if (a == null) return NotFound();

        a.Name = req.Name;
        a.Address = req.Address;
        a.Description = req.Description;
        a.Notes = req.Notes;
        await _context.SaveChangesAsync();
        return Ok(Map(a));
    }

    [HttpDelete("{id}")]
    [Authorize(Roles = "Owner")]
    public async Task<IActionResult> Delete(Guid id)
    {
        var a = await _context.Apartments.FindAsync(id);
        if (a == null) return NotFound();
        _context.Apartments.Remove(a);
        await _context.SaveChangesAsync();
        return NoContent();
    }

    private static ApartmentResponse Map(Apartment a) =>
        new(a.Id, a.Name, a.Address, a.Description, a.Notes, a.CreatedAt);
}
