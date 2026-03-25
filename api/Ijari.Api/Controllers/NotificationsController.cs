using Ijari.Api.DTOs;
using Ijari.Core.Interfaces;
using Ijari.Infrastructure.Data;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Ijari.Api.Controllers;

[ApiController]
[Route("api/notifications")]
[Authorize]
public class NotificationsController : ControllerBase
{
    private readonly AppDbContext _context;
    private readonly ICurrentTenant _tenant;

    public NotificationsController(AppDbContext context, ICurrentTenant tenant)
    {
        _context = context;
        _tenant = tenant;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<NotificationResponse>>> GetAll()
    {
        var list = await _context.Notifications
            .Where(n => n.UserId == _tenant.UserId)
            .OrderByDescending(n => n.CreatedAt)
            .Take(50)
            .ToListAsync();

        return Ok(list.Select(n => new NotificationResponse(
            n.Id, n.Title, n.Body, n.IsRead, n.EntityType?.ToString(), n.EntityId, n.CreatedAt)));
    }

    [HttpPut("{id}/read")]
    public async Task<IActionResult> MarkRead(Guid id)
    {
        var n = await _context.Notifications.FirstOrDefaultAsync(n => n.Id == id && n.UserId == _tenant.UserId);
        if (n == null) return NotFound();
        n.IsRead = true;
        await _context.SaveChangesAsync();
        return NoContent();
    }

    [HttpPut("read-all")]
    public async Task<IActionResult> MarkAllRead()
    {
        var unread = await _context.Notifications
            .Where(n => n.UserId == _tenant.UserId && !n.IsRead)
            .ToListAsync();
        foreach (var n in unread) n.IsRead = true;
        await _context.SaveChangesAsync();
        return NoContent();
    }

    [HttpGet("unread-count")]
    public async Task<ActionResult<int>> UnreadCount() =>
        Ok(await _context.Notifications.CountAsync(n => n.UserId == _tenant.UserId && !n.IsRead));
}
