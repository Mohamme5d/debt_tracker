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
[Authorize]
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

        IQueryable<Guid> assignedIds = null!;
        if (!_tenant.IsOwner)
        {
            assignedIds = _context.ApartmentAssignments
                .Where(a => a.EmployeeId == _tenant.UserId)
                .Select(a => a.ApartmentId);
        }

        var aptQuery = _context.Apartments.AsQueryable();
        var renterQuery = _context.Renters.Where(r => r.IsActive && r.Status == RecordStatus.Approved);
        var payQuery = _context.RentPayments.Where(p => p.PaymentMonth == month && p.PaymentYear == year && p.Status == RecordStatus.Approved);
        var outstandingQuery = _context.RentPayments.Where(p => p.Status == RecordStatus.Approved);
        var expQuery = _context.Expenses.Where(e => e.Month == month && e.Year == year && e.Status == RecordStatus.Approved);

        if (!_tenant.IsOwner)
        {
            aptQuery = aptQuery.Where(a => assignedIds.Contains(a.Id));
            renterQuery = renterQuery.Where(r => assignedIds.Contains(r.ApartmentId));
            payQuery = payQuery.Where(p => assignedIds.Contains(p.ApartmentId));
            outstandingQuery = outstandingQuery.Where(p => assignedIds.Contains(p.ApartmentId));
            expQuery = expQuery.Where(e => e.SubmittedById == _tenant.UserId);
        }

        var totalApartments = await aptQuery.CountAsync();
        var activeRenters = await renterQuery.CountAsync();
        var collectedThisMonth = await payQuery.SumAsync(p => (decimal?)p.AmountPaid) ?? 0;
        var totalOutstanding = await outstandingQuery.SumAsync(p => (decimal?)p.OutstandingAfter) ?? 0;
        var totalExpenses = await expQuery.SumAsync(e => (decimal?)e.Amount) ?? 0;
        var pendingApprovals = _tenant.IsOwner
            ? await _context.ApprovalRequests.CountAsync(r => r.Status == ApprovalStatus.Pending)
            : 0;
        var unread = await _context.Notifications.CountAsync(n => n.UserId == _tenant.UserId && !n.IsRead);

        return Ok(new DashboardStats(totalApartments, activeRenters, collectedThisMonth, totalOutstanding, totalExpenses, pendingApprovals, unread));
    }

    [HttpGet("trend")]
    public async Task<ActionResult<IEnumerable<MonthlyTrendPoint>>> Trend()
    {
        var now = DateTime.UtcNow;
        var points = new List<MonthlyTrendPoint>();

        IQueryable<Guid>? assignedIds = null;
        if (!_tenant.IsOwner)
        {
            assignedIds = _context.ApartmentAssignments
                .Where(a => a.EmployeeId == _tenant.UserId)
                .Select(a => a.ApartmentId);
        }

        for (int i = 5; i >= 0; i--)
        {
            var date = now.AddMonths(-i);
            var m = date.Month;
            var y = date.Year;

            var payQuery = _context.RentPayments
                .Where(p => p.PaymentMonth == m && p.PaymentYear == y && p.Status == RecordStatus.Approved);
            var expQuery = _context.Expenses
                .Where(e => e.Month == m && e.Year == y && e.Status == RecordStatus.Approved);

            if (!_tenant.IsOwner && assignedIds != null)
            {
                payQuery = payQuery.Where(p => assignedIds.Contains(p.ApartmentId));
                expQuery = expQuery.Where(e => e.SubmittedById == _tenant.UserId);
            }

            var collected = await payQuery.SumAsync(p => (decimal?)p.AmountPaid) ?? 0;
            var expenses = await expQuery.SumAsync(e => (decimal?)e.Amount) ?? 0;

            points.Add(new MonthlyTrendPoint(m, y, collected, expenses));
        }

        return Ok(points);
    }
}
