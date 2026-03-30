using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Ijari.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class DropRenterOldColumns : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Drop FK and index on ApartmentId (EF Core naming convention)
            migrationBuilder.DropForeignKey(
                name: "FK_Renters_Apartments_ApartmentId",
                table: "Renters");

            migrationBuilder.DropIndex(
                name: "IX_Renters_ApartmentId",
                table: "Renters");

            // Drop old columns moved to RentContract
            migrationBuilder.DropColumn(name: "ApartmentId", table: "Renters");
            migrationBuilder.DropColumn(name: "MonthlyRent",  table: "Renters");
            migrationBuilder.DropColumn(name: "StartDate",    table: "Renters");
            migrationBuilder.DropColumn(name: "IsActive",     table: "Renters");

            // Add ContractId to RentPayments
            migrationBuilder.Sql(@"
                ALTER TABLE `RentPayments`
                ADD COLUMN IF NOT EXISTS `ContractId` char(36) NULL;
            ");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {

        }
    }
}
