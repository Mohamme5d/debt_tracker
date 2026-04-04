using ClosedXML.Excel;
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

    [HttpGet("renter-apartment")]
    public async Task<ActionResult<RenterApartmentReportResponse>> RenterApartment(
        [FromQuery] Guid? apartmentId, [FromQuery] Guid? renterId)
    {
        var query = _context.RentPayments
            .Include(p => p.Apartment)
            .Include(p => p.Renter)
            .Where(p => p.Status == RecordStatus.Approved)
            .AsQueryable();

        if (apartmentId.HasValue)
            query = query.Where(p => p.ApartmentId == apartmentId.Value);
        if (renterId.HasValue)
            query = query.Where(p => p.RenterId == renterId.Value);

        var payments = await query
            .OrderBy(p => p.PaymentYear).ThenBy(p => p.PaymentMonth)
            .ToListAsync();

        var rows = payments.Select(p => new RenterApartmentReportRow(
            p.Apartment?.Name ?? "",
            p.Renter?.Name,
            p.PaymentMonth,
            p.PaymentYear,
            p.AmountPaid,
            p.OutstandingAfter
        )).ToList();

        return Ok(new RenterApartmentReportResponse(
            rows,
            rows.Sum(r => r.AmountPaid),
            rows.Count > 0 ? rows.Last().OutstandingAfter : 0
        ));
    }

    [HttpGet("all-time")]
    public async Task<ActionResult<AllTimeReportResponse>> AllTime()
    {
        var payments = await _context.RentPayments
            .Include(p => p.Apartment)
            .Include(p => p.Renter)
            .Where(p => p.Status == RecordStatus.Approved)
            .ToListAsync();

        var expenses = await _context.Expenses
            .Where(e => e.Status == RecordStatus.Approved)
            .ToListAsync();

        var deposits = await _context.MonthlyDeposits
            .Where(d => d.Status == RecordStatus.Approved)
            .SumAsync(d => (decimal?)d.Amount) ?? 0;

        var totalRent = payments.Sum(p => p.AmountPaid);
        var totalExp = expenses.Sum(e => e.Amount);

        var apartments = payments
            .GroupBy(p => p.ApartmentId)
            .Select(g =>
            {
                var last = g.OrderByDescending(p => p.PaymentYear).ThenByDescending(p => p.PaymentMonth).First();
                return new ApartmentSummary(
                    last.Apartment?.Name ?? "",
                    last.Renter?.Name,
                    g.Sum(p => p.AmountPaid),
                    last.OutstandingAfter
                );
            }).ToList();

        var totalOutstanding = apartments.Sum(a => a.TotalOutstanding);

        var expenseCategories = expenses
            .GroupBy(e => e.Category ?? "Uncategorized")
            .Select(g => new ExpenseCategorySummary(g.Key, g.Sum(e => e.Amount)))
            .ToList();

        return Ok(new AllTimeReportResponse(
            totalRent, totalOutstanding, totalExp, deposits, totalRent - totalExp,
            apartments, expenseCategories
        ));
    }

    [HttpGet("export/monthly")]
    public async Task<IActionResult> ExportMonthly([FromQuery] int month, [FromQuery] int year)
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

        using var workbook = new XLWorkbook();

        var wsSummary = workbook.Worksheets.Add("Summary");
        wsSummary.Cell(1, 1).Value = $"Monthly Report — {month}/{year}";
        wsSummary.Cell(1, 1).Style.Font.Bold = true;
        wsSummary.Cell(1, 1).Style.Font.FontSize = 14;
        wsSummary.Cell(3, 1).Value = "Total Rent Collected"; wsSummary.Cell(3, 2).Value = payments.Sum(p => p.AmountPaid);
        wsSummary.Cell(4, 1).Value = "Total Outstanding";    wsSummary.Cell(4, 2).Value = payments.Sum(p => p.OutstandingAfter);
        wsSummary.Cell(5, 1).Value = "Total Expenses";       wsSummary.Cell(5, 2).Value = expenses.Sum(e => e.Amount);
        wsSummary.Cell(6, 1).Value = "Total Deposit";        wsSummary.Cell(6, 2).Value = deposit;
        wsSummary.Cell(7, 1).Value = "Net Balance";          wsSummary.Cell(7, 2).Value = payments.Sum(p => p.AmountPaid) - expenses.Sum(e => e.Amount);
        wsSummary.Column(1).Style.Font.Bold = true;
        wsSummary.Columns().AdjustToContents();

        var wsPayments = workbook.Worksheets.Add("Payments");
        wsPayments.Cell(1, 1).Value = "Apartment"; wsPayments.Cell(1, 2).Value = "Renter";
        wsPayments.Cell(1, 3).Value = "Amount Paid"; wsPayments.Cell(1, 4).Value = "Outstanding After";
        wsPayments.Row(1).Style.Font.Bold = true;
        for (int i = 0; i < payments.Count; i++)
        {
            var p = payments[i];
            wsPayments.Cell(i + 2, 1).Value = p.Apartment?.Name ?? "";
            wsPayments.Cell(i + 2, 2).Value = p.Renter?.Name ?? "—";
            wsPayments.Cell(i + 2, 3).Value = p.AmountPaid;
            wsPayments.Cell(i + 2, 4).Value = p.OutstandingAfter;
        }
        wsPayments.Columns().AdjustToContents();

        var wsExpenses = workbook.Worksheets.Add("Expenses");
        wsExpenses.Cell(1, 1).Value = "Description"; wsExpenses.Cell(1, 2).Value = "Category"; wsExpenses.Cell(1, 3).Value = "Amount";
        wsExpenses.Row(1).Style.Font.Bold = true;
        for (int i = 0; i < expenses.Count; i++)
        {
            var e = expenses[i];
            wsExpenses.Cell(i + 2, 1).Value = e.Description;
            wsExpenses.Cell(i + 2, 2).Value = e.Category ?? "";
            wsExpenses.Cell(i + 2, 3).Value = e.Amount;
        }
        wsExpenses.Columns().AdjustToContents();

        using var stream = new MemoryStream();
        workbook.SaveAs(stream);
        return File(stream.ToArray(),
            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
            $"monthly-report-{year}-{month:D2}.xlsx");
    }

    [HttpGet("export/all-time")]
    public async Task<IActionResult> ExportAllTime()
    {
        var payments = await _context.RentPayments
            .Include(p => p.Apartment).Include(p => p.Renter)
            .Where(p => p.Status == RecordStatus.Approved)
            .OrderBy(p => p.PaymentYear).ThenBy(p => p.PaymentMonth)
            .ToListAsync();

        var expenses = await _context.Expenses
            .Where(e => e.Status == RecordStatus.Approved)
            .OrderBy(e => e.Year).ThenBy(e => e.Month)
            .ToListAsync();

        using var workbook = new XLWorkbook();

        var wsPayments = workbook.Worksheets.Add("All Payments");
        wsPayments.Cell(1, 1).Value = "Month"; wsPayments.Cell(1, 2).Value = "Year";
        wsPayments.Cell(1, 3).Value = "Apartment"; wsPayments.Cell(1, 4).Value = "Renter";
        wsPayments.Cell(1, 5).Value = "Amount Paid"; wsPayments.Cell(1, 6).Value = "Outstanding After";
        wsPayments.Row(1).Style.Font.Bold = true;
        for (int i = 0; i < payments.Count; i++)
        {
            var p = payments[i];
            wsPayments.Cell(i + 2, 1).Value = p.PaymentMonth;
            wsPayments.Cell(i + 2, 2).Value = p.PaymentYear;
            wsPayments.Cell(i + 2, 3).Value = p.Apartment?.Name ?? "";
            wsPayments.Cell(i + 2, 4).Value = p.Renter?.Name ?? "—";
            wsPayments.Cell(i + 2, 5).Value = p.AmountPaid;
            wsPayments.Cell(i + 2, 6).Value = p.OutstandingAfter;
        }
        wsPayments.Columns().AdjustToContents();

        var wsExpenses = workbook.Worksheets.Add("All Expenses");
        wsExpenses.Cell(1, 1).Value = "Month"; wsExpenses.Cell(1, 2).Value = "Year";
        wsExpenses.Cell(1, 3).Value = "Description"; wsExpenses.Cell(1, 4).Value = "Category"; wsExpenses.Cell(1, 5).Value = "Amount";
        wsExpenses.Row(1).Style.Font.Bold = true;
        for (int i = 0; i < expenses.Count; i++)
        {
            var e = expenses[i];
            wsExpenses.Cell(i + 2, 1).Value = e.Month;
            wsExpenses.Cell(i + 2, 2).Value = e.Year;
            wsExpenses.Cell(i + 2, 3).Value = e.Description;
            wsExpenses.Cell(i + 2, 4).Value = e.Category ?? "";
            wsExpenses.Cell(i + 2, 5).Value = e.Amount;
        }
        wsExpenses.Columns().AdjustToContents();

        var wsApartments = workbook.Worksheets.Add("By Apartment");
        wsApartments.Cell(1, 1).Value = "Apartment"; wsApartments.Cell(1, 2).Value = "Current Renter";
        wsApartments.Cell(1, 3).Value = "Total Paid"; wsApartments.Cell(1, 4).Value = "Outstanding";
        wsApartments.Row(1).Style.Font.Bold = true;
        var aptGroups = payments.GroupBy(p => p.ApartmentId).ToList();
        for (int i = 0; i < aptGroups.Count; i++)
        {
            var g = aptGroups[i];
            var last = g.OrderByDescending(p => p.PaymentYear).ThenByDescending(p => p.PaymentMonth).First();
            wsApartments.Cell(i + 2, 1).Value = last.Apartment?.Name ?? "";
            wsApartments.Cell(i + 2, 2).Value = last.Renter?.Name ?? "—";
            wsApartments.Cell(i + 2, 3).Value = g.Sum(p => p.AmountPaid);
            wsApartments.Cell(i + 2, 4).Value = last.OutstandingAfter;
        }
        wsApartments.Columns().AdjustToContents();

        using var stream = new MemoryStream();
        workbook.SaveAs(stream);
        return File(stream.ToArray(),
            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
            "all-time-report.xlsx");
    }
}
