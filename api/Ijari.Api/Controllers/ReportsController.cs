using Ijari.Api.DTOs;
using Ijari.Core.Enums;
using Ijari.Core.Interfaces;
using Ijari.Infrastructure.Data;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Ijari.Api.Controllers;

[ApiController]
[Route("api/reports")]
[Authorize]
public class ReportsController : ControllerBase
{
    private readonly AppDbContext _context;
    private readonly ICurrentTenant _tenant;

    public ReportsController(AppDbContext context, ICurrentTenant tenant)
    {
        _context = context;
        _tenant = tenant;
    }

    [HttpGet("monthly")]
    public async Task<ActionResult<MonthlyReportResponse>> Monthly([FromQuery] int month, [FromQuery] int year)
    {
        IQueryable<Core.Entities.RentPayment> payQuery = _context.RentPayments
            .Include(p => p.Apartment).Include(p => p.Renter)
            .Where(p => p.PaymentMonth == month && p.PaymentYear == year && p.Status == RecordStatus.Approved);

        IQueryable<Core.Entities.Expense> expQuery = _context.Expenses
            .Where(e => e.Month == month && e.Year == year && e.Status == RecordStatus.Approved);

        IQueryable<Core.Entities.MonthlyDeposit> depQuery = _context.MonthlyDeposits
            .Where(d => d.DepositMonth == month && d.DepositYear == year && d.Status == RecordStatus.Approved);

        if (!_tenant.IsOwner)
        {
            var assigned = _context.ApartmentAssignments
                .Where(a => a.EmployeeId == _tenant.UserId)
                .Select(a => a.ApartmentId);

            payQuery = payQuery.Where(p => assigned.Contains(p.ApartmentId));
            // expenses and deposits are filtered to what the employee submitted
            expQuery = expQuery.Where(e => e.SubmittedById == _tenant.UserId);
            depQuery = depQuery.Where(d => d.SubmittedById == _tenant.UserId);
        }

        var payments = await payQuery.ToListAsync();
        var expenses = await expQuery.ToListAsync();
        var deposit = await depQuery.SumAsync(d => (decimal?)d.Amount) ?? 0;

        var totalRent = payments.Sum(p => p.AmountPaid);
        var totalOutstanding = payments.Sum(p => p.OutstandingAfter);
        var totalExp = expenses.Sum(e => e.Amount);
        var net = totalRent - totalExp;

        return Ok(new MonthlyReportResponse(
            month, year, totalRent, totalOutstanding, totalExp, deposit, net,
            payments.Select(p => new PaymentSummary(p.Apartment?.Name ?? "", p.Renter?.Name, p.AmountPaid, p.OutstandingAfter)).ToList(),
            expenses.Select(e => new ExpenseSummary(e.Description, e.Category, e.Amount)).ToList()
        ));
    }

    [HttpGet("commission")]
    [Authorize(Roles = "Owner")]
    public async Task<ActionResult<CommissionReportResponse>> Commission([FromQuery] int month, [FromQuery] int year, [FromQuery] decimal rate = 10)
    {
        var totalRent = await _context.RentPayments
            .Where(p => p.PaymentMonth == month && p.PaymentYear == year && p.Status == RecordStatus.Approved && !p.IsVacant)
            .SumAsync(p => (decimal?)p.AmountPaid) ?? 0;

        var commission = totalRent * (rate / 100);
        return Ok(new CommissionReportResponse(month, year, totalRent, rate, commission));
    }
}
