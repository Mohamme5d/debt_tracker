using Ijari.Core.Entities;
using Ijari.Core.Enums;
using Ijari.Core.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace Ijari.Infrastructure.Data;

public class AppDbContext : DbContext
{
    private readonly ICurrentTenant? _currentTenant;

    public AppDbContext(DbContextOptions<AppDbContext> options, ICurrentTenant? currentTenant = null)
        : base(options)
    {
        _currentTenant = currentTenant;
    }

    public DbSet<Tenant> Tenants => Set<Tenant>();
    public DbSet<User> Users => Set<User>();
    public DbSet<RefreshToken> RefreshTokens => Set<RefreshToken>();
    public DbSet<Apartment> Apartments => Set<Apartment>();
    public DbSet<Renter> Renters => Set<Renter>();
    public DbSet<RentContract> RentContracts => Set<RentContract>();
    public DbSet<RentPayment> RentPayments => Set<RentPayment>();
    public DbSet<Expense> Expenses => Set<Expense>();
    public DbSet<MonthlyDeposit> MonthlyDeposits => Set<MonthlyDeposit>();
    public DbSet<ApprovalRequest> ApprovalRequests => Set<ApprovalRequest>();
    public DbSet<Notification> Notifications => Set<Notification>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Global tenant filters — reference _currentTenant field (not a captured local value)
        // so EF Core re-evaluates against the correct context instance per request
        modelBuilder.Entity<User>().HasQueryFilter(e => _currentTenant == null || e.TenantId == _currentTenant.Id);
        modelBuilder.Entity<Apartment>().HasQueryFilter(e => _currentTenant == null || e.TenantId == _currentTenant.Id);
        modelBuilder.Entity<Renter>().HasQueryFilter(e => _currentTenant == null || e.TenantId == _currentTenant.Id);
        modelBuilder.Entity<RentContract>().HasQueryFilter(e => _currentTenant == null || e.TenantId == _currentTenant.Id);
        modelBuilder.Entity<RentPayment>().HasQueryFilter(e => _currentTenant == null || e.TenantId == _currentTenant.Id);
        modelBuilder.Entity<Expense>().HasQueryFilter(e => _currentTenant == null || e.TenantId == _currentTenant.Id);
        modelBuilder.Entity<MonthlyDeposit>().HasQueryFilter(e => _currentTenant == null || e.TenantId == _currentTenant.Id);
        modelBuilder.Entity<ApprovalRequest>().HasQueryFilter(e => _currentTenant == null || e.TenantId == _currentTenant.Id);
        modelBuilder.Entity<Notification>().HasQueryFilter(e => _currentTenant == null || e.TenantId == _currentTenant.Id);

        // Unique constraints
        modelBuilder.Entity<RentPayment>().HasIndex(e => new
        {
            e.TenantId, e.ApartmentId, e.PaymentMonth, e.PaymentYear
        }).IsUnique();

        modelBuilder.Entity<MonthlyDeposit>().HasIndex(e => new
        {
            e.TenantId, e.DepositMonth, e.DepositYear
        }).IsUnique();

        modelBuilder.Entity<User>().HasIndex(e => e.Email).IsUnique();

        // Enum storage
        modelBuilder.Entity<User>().Property(e => e.Role).HasConversion<string>();
        modelBuilder.Entity<Renter>().Property(e => e.Status).HasConversion<string>();
        modelBuilder.Entity<RentContract>().Property(e => e.Status).HasConversion<string>();
        modelBuilder.Entity<RentPayment>().Property(e => e.Status).HasConversion<string>();
        modelBuilder.Entity<Expense>().Property(e => e.Status).HasConversion<string>();
        modelBuilder.Entity<MonthlyDeposit>().Property(e => e.Status).HasConversion<string>();
        modelBuilder.Entity<ApprovalRequest>().Property(e => e.Status).HasConversion<string>();
        modelBuilder.Entity<ApprovalRequest>().Property(e => e.EntityType).HasConversion<string>();
        modelBuilder.Entity<ApprovalRequest>().Property(e => e.Action).HasConversion<string>();
        modelBuilder.Entity<Notification>().Property(e => e.EntityType).HasConversion<string>();

        // Decimal precision
        modelBuilder.Entity<RentContract>().Property(e => e.MonthlyRent).HasPrecision(18, 2);
        modelBuilder.Entity<RentPayment>().Property(e => e.RentAmount).HasPrecision(18, 2);
        modelBuilder.Entity<RentPayment>().Property(e => e.OutstandingBefore).HasPrecision(18, 2);
        modelBuilder.Entity<RentPayment>().Property(e => e.AmountPaid).HasPrecision(18, 2);
        modelBuilder.Entity<RentPayment>().Property(e => e.OutstandingAfter).HasPrecision(18, 2);
        modelBuilder.Entity<Expense>().Property(e => e.Amount).HasPrecision(18, 2);
        modelBuilder.Entity<MonthlyDeposit>().Property(e => e.Amount).HasPrecision(18, 2);

        // Relationships — prevent cascade cycles
        modelBuilder.Entity<Renter>()
            .HasOne(r => r.SubmittedBy).WithMany().HasForeignKey(r => r.SubmittedById)
            .OnDelete(DeleteBehavior.Restrict);
        modelBuilder.Entity<Renter>()
            .HasOne(r => r.ApprovedBy).WithMany().HasForeignKey(r => r.ApprovedById)
            .OnDelete(DeleteBehavior.Restrict);
        modelBuilder.Entity<RentContract>()
            .HasOne(r => r.Renter).WithMany().HasForeignKey(r => r.RenterId)
            .OnDelete(DeleteBehavior.Restrict);
        modelBuilder.Entity<RentContract>()
            .HasOne(r => r.Apartment).WithMany().HasForeignKey(r => r.ApartmentId)
            .OnDelete(DeleteBehavior.Restrict);
        modelBuilder.Entity<RentContract>()
            .HasOne(r => r.SubmittedBy).WithMany().HasForeignKey(r => r.SubmittedById)
            .OnDelete(DeleteBehavior.Restrict);
        modelBuilder.Entity<RentContract>()
            .HasOne(r => r.ApprovedBy).WithMany().HasForeignKey(r => r.ApprovedById)
            .OnDelete(DeleteBehavior.Restrict);
        modelBuilder.Entity<RentPayment>()
            .HasOne(r => r.Contract).WithMany().HasForeignKey(r => r.ContractId)
            .OnDelete(DeleteBehavior.Restrict);
        modelBuilder.Entity<RentPayment>()
            .HasOne(r => r.SubmittedBy).WithMany().HasForeignKey(r => r.SubmittedById)
            .OnDelete(DeleteBehavior.Restrict);
        modelBuilder.Entity<RentPayment>()
            .HasOne(r => r.ApprovedBy).WithMany().HasForeignKey(r => r.ApprovedById)
            .OnDelete(DeleteBehavior.Restrict);
        modelBuilder.Entity<Expense>()
            .HasOne(r => r.SubmittedBy).WithMany().HasForeignKey(r => r.SubmittedById)
            .OnDelete(DeleteBehavior.Restrict);
        modelBuilder.Entity<Expense>()
            .HasOne(r => r.ApprovedBy).WithMany().HasForeignKey(r => r.ApprovedById)
            .OnDelete(DeleteBehavior.Restrict);
        modelBuilder.Entity<MonthlyDeposit>()
            .HasOne(r => r.SubmittedBy).WithMany().HasForeignKey(r => r.SubmittedById)
            .OnDelete(DeleteBehavior.Restrict);
        modelBuilder.Entity<MonthlyDeposit>()
            .HasOne(r => r.ApprovedBy).WithMany().HasForeignKey(r => r.ApprovedById)
            .OnDelete(DeleteBehavior.Restrict);
        modelBuilder.Entity<ApprovalRequest>()
            .HasOne(r => r.ReviewedBy).WithMany().HasForeignKey(r => r.ReviewedById)
            .OnDelete(DeleteBehavior.Restrict);
    }
}
