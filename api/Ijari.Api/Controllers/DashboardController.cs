using Ijari.Api.DTOs;
using Ijari.Core.Enums;
using Ijari.Core.Interfaces;
using Ijari.Infrastructure.Data;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Ijari.Api.Controllers;

[ApiController]
[Route("api/dashboard")]
[Authorize(Roles = "Owner")]
public class DashboardController : ControllerBase
{
    private readonly AppDbContext _context;
    private readonly ICurrentTenant _tenant;

    public DashboardController(AppDbContext context, ICurrentTenant tenant)
    {
        _context = context;
        _tenant = tenant;
    }

    [HttpGet]
    public async Task<ActionResult<DashboardStats>> Get()
    {
        var now = DateTime.UtcNow;
        var month = now.Month;
        var year = now.Year;

        var totalApartments = await _context.Apartments.CountAsync();
        var activeRenters = await _context.Renters.CountAsync(r => r.IsActive && r.Status == RecordStatus.Approved);
        var collectedThisMonth = await _context.RentPayments
            .Where(p => p.PaymentMonth == month && p.PaymentYear == year && p.Status == RecordStatus.Approved)
            .SumAsync(p => (decimal?)p.AmountPaid) ?? 0;
        var totalOutstanding = await _context.RentPayments
            .Where(p => p.Status == RecordStatus.Approved)
            .SumAsync(p => (decimal?)p.OutstandingAfter) ?? 0;
        var totalExpenses = await _context.Expenses
            .Where(e => e.Month == month && e.Year == year && e.Status == RecordStatus.Approved)
            .SumAsync(e => (decimal?)e.Amount) ?? 0;
        var pendingApprovals = await _context.ApprovalRequests.CountAsync(r => r.Status == ApprovalStatus.Pending);
        var unread = await _context.Notifications.CountAsync(n => n.UserId == _tenant.UserId && !n.IsRead);

        return Ok(new DashboardStats(totalApartments, activeRenters, collectedThisMonth, totalOutstanding, totalExpenses, pendingApprovals, unread));
    }
}
