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
[Route("api/employees")]
[Authorize(Roles = "Owner")]
public class EmployeesController : ControllerBase
{
    private readonly AppDbContext _context;
    private readonly ICurrentTenant _tenant;

    public EmployeesController(AppDbContext context, ICurrentTenant tenant)
    {
        _context = context;
        _tenant = tenant;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<UserDto>>> GetAll()
    {
        var employees = await _context.Users
            .Where(u => u.Role == UserRole.Employee)
            .ToListAsync();
        return Ok(employees.Select(u => new UserDto(u.Id, u.TenantId, u.Name, u.Email, u.Role.ToString(), u.Phone, u.IsActive)));
    }

    [HttpPost]
    public async Task<ActionResult<UserDto>> Invite(InviteEmployeeRequest req)
    {
        if (await _context.Users.IgnoreQueryFilters().AnyAsync(u => u.Email == req.Email))
            return Conflict(new { message = "Email already registered" });

        var user = new User
        {
            TenantId = _tenant.Id,
            Name = req.Name,
            Email = req.Email,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(req.Password),
            Role = UserRole.Employee,
            Phone = req.Phone
        };
        _context.Users.Add(user);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetAll), new UserDto(user.Id, user.TenantId, user.Name, user.Email, user.Role.ToString(), user.Phone, user.IsActive));
    }

    [HttpPut("{id}")]
    public async Task<ActionResult<UserDto>> Update(Guid id, UpdateEmployeeRequest req)
    {
        var user = await _context.Users.FirstOrDefaultAsync(u => u.Id == id && u.Role == UserRole.Employee);
        if (user == null) return NotFound();

        user.Name = req.Name;
        user.Phone = req.Phone;
        user.IsActive = req.IsActive;
        await _context.SaveChangesAsync();

        return Ok(new UserDto(user.Id, user.TenantId, user.Name, user.Email, user.Role.ToString(), user.Phone, user.IsActive));
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(Guid id)
    {
        var user = await _context.Users.FirstOrDefaultAsync(u => u.Id == id && u.Role == UserRole.Employee);
        if (user == null) return NotFound();
        _context.Users.Remove(user);
        await _context.SaveChangesAsync();
        return NoContent();
    }

    // ── Apartment assignments ─────────────────────────────────────────────────

    [HttpGet("{id}/apartments")]
    public async Task<ActionResult<IEnumerable<object>>> GetAssignedApartments(Guid id)
    {
        var assignments = await _context.ApartmentAssignments
            .Include(a => a.Apartment)
            .Where(a => a.EmployeeId == id)
            .Select(a => new { a.ApartmentId, a.Apartment.Name })
            .ToListAsync();
        return Ok(assignments);
    }

    [HttpPut("{id}/apartments")]
    public async Task<IActionResult> SetAssignedApartments(Guid id, [FromBody] List<Guid> apartmentIds)
    {
        var employee = await _context.Users.FirstOrDefaultAsync(u => u.Id == id && u.Role == UserRole.Employee);
        if (employee == null) return NotFound();

        // Remove existing assignments
        var existing = await _context.ApartmentAssignments.Where(a => a.EmployeeId == id).ToListAsync();
        _context.ApartmentAssignments.RemoveRange(existing);

        // Add new assignments
        foreach (var aptId in apartmentIds.Distinct())
        {
            _context.ApartmentAssignments.Add(new ApartmentAssignment
            {
                TenantId = _tenant.Id,
                EmployeeId = id,
                ApartmentId = aptId
            });
        }

        await _context.SaveChangesAsync();
        return NoContent();
    }
}
