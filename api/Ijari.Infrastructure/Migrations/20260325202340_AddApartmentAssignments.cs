using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Ijari.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddApartmentAssignments : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "ApartmentAssignments",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    EmployeeId = table.Column<Guid>(type: "uuid", nullable: false),
                    ApartmentId = table.Column<Guid>(type: "uuid", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    TenantId = table.Column<Guid>(type: "uuid", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ApartmentAssignments", x => x.Id);
                    table.ForeignKey(
                        name: "FK_ApartmentAssignments_Apartments_ApartmentId",
                        column: x => x.ApartmentId,
                        principalTable: "Apartments",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_ApartmentAssignments_Tenants_TenantId",
                        column: x => x.TenantId,
                        principalTable: "Tenants",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_ApartmentAssignments_Users_EmployeeId",
                        column: x => x.EmployeeId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_ApartmentAssignments_ApartmentId",
                table: "ApartmentAssignments",
                column: "ApartmentId");

            migrationBuilder.CreateIndex(
                name: "IX_ApartmentAssignments_EmployeeId",
                table: "ApartmentAssignments",
                column: "EmployeeId");

            migrationBuilder.CreateIndex(
                name: "IX_ApartmentAssignments_TenantId_EmployeeId_ApartmentId",
                table: "ApartmentAssignments",
                columns: new[] { "TenantId", "EmployeeId", "ApartmentId" },
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "ApartmentAssignments");
        }
    }
}
