using Ijari.Api.DTOs;
using Ijari.Core.Enums;
using Ijari.Infrastructure.Data;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Ijari.Api.Controllers;

[ApiController]
[Route("api/reports")]
[Authorize(Roles = "Owner")]
public class ReportsController : ControllerBase
{
    private readonly AppDbContext _context;

    public ReportsController(AppDbContext context)
    {
        _context = context;
    }

    [HttpGet("monthly")]
    public async Task<ActionResult<MonthlyReportResponse>> Monthly([FromQuery] int month, [FromQuery] int year)
    {
        var payments = await _context.RentPayments
            .Include(p => p.Apartment).Include(p => p.Renter)
            .Where(p => p.PaymentMonth == month && p.PaymentYear == year && p.Status == RecordStatus.Approved)
            .ToListAsync();

        var expenses = await _context.Expenses
            .Where(e => e.Month == month && e.Year == year && e.Status == RecordStatus.Approved)
            .ToListAsync();

        var deposit = await _context.MonthlyDeposits
            .Where(d => d.DepositMonth == month && d.DepositYear == year && d.Status == RecordStatus.Approved)
            .SumAsync(d => (decimal?)d.Amount) ?? 0;

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
    public async Task<ActionResult<CommissionReportResponse>> Commission([FromQuery] int month, [FromQuery] int year, [FromQuery] decimal rate = 10)
    {
        var totalRent = await _context.RentPayments
            .Where(p => p.PaymentMonth == month && p.PaymentYear == year && p.Status == RecordStatus.Approved && !p.IsVacant)
            .SumAsync(p => (decimal?)p.AmountPaid) ?? 0;

        var commission = totalRent * (rate / 100);
        return Ok(new CommissionReportResponse(month, year, totalRent, rate, commission));
    }
}
