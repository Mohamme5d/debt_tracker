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
            // Drop FK, index, and columns only if they exist (idempotent)
            migrationBuilder.Sql(@"
                SET @fk_exists = (SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS
                    WHERE CONSTRAINT_SCHEMA = DATABASE()
                      AND TABLE_NAME = 'Renters'
                      AND CONSTRAINT_NAME = 'FK_Renters_Apartments_ApartmentId'
                      AND CONSTRAINT_TYPE = 'FOREIGN KEY');
                SET @stmt = IF(@fk_exists > 0,
                    'ALTER TABLE `Renters` DROP FOREIGN KEY `FK_Renters_Apartments_ApartmentId`',
                    'SELECT 1');
                PREPARE s FROM @stmt; EXECUTE s; DEALLOCATE PREPARE s;
            ");

            migrationBuilder.Sql(@"
                SET @idx_exists = (SELECT COUNT(*) FROM information_schema.STATISTICS
                    WHERE TABLE_SCHEMA = DATABASE()
                      AND TABLE_NAME = 'Renters'
                      AND INDEX_NAME = 'IX_Renters_ApartmentId');
                SET @stmt = IF(@idx_exists > 0,
                    'ALTER TABLE `Renters` DROP INDEX `IX_Renters_ApartmentId`',
                    'SELECT 1');
                PREPARE s FROM @stmt; EXECUTE s; DEALLOCATE PREPARE s;
            ");

            migrationBuilder.Sql(@"
                SET @col_exists = (SELECT COUNT(*) FROM information_schema.COLUMNS
                    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'Renters' AND COLUMN_NAME = 'ApartmentId');
                SET @stmt = IF(@col_exists > 0, 'ALTER TABLE `Renters` DROP COLUMN `ApartmentId`', 'SELECT 1');
                PREPARE s FROM @stmt; EXECUTE s; DEALLOCATE PREPARE s;
            ");
            migrationBuilder.Sql(@"
                SET @col_exists = (SELECT COUNT(*) FROM information_schema.COLUMNS
                    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'Renters' AND COLUMN_NAME = 'MonthlyRent');
                SET @stmt = IF(@col_exists > 0, 'ALTER TABLE `Renters` DROP COLUMN `MonthlyRent`', 'SELECT 1');
                PREPARE s FROM @stmt; EXECUTE s; DEALLOCATE PREPARE s;
            ");
            migrationBuilder.Sql(@"
                SET @col_exists = (SELECT COUNT(*) FROM information_schema.COLUMNS
                    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'Renters' AND COLUMN_NAME = 'StartDate');
                SET @stmt = IF(@col_exists > 0, 'ALTER TABLE `Renters` DROP COLUMN `StartDate`', 'SELECT 1');
                PREPARE s FROM @stmt; EXECUTE s; DEALLOCATE PREPARE s;
            ");
            migrationBuilder.Sql(@"
                SET @col_exists = (SELECT COUNT(*) FROM information_schema.COLUMNS
                    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'Renters' AND COLUMN_NAME = 'IsActive');
                SET @stmt = IF(@col_exists > 0, 'ALTER TABLE `Renters` DROP COLUMN `IsActive`', 'SELECT 1');
                PREPARE s FROM @stmt; EXECUTE s; DEALLOCATE PREPARE s;
            ");

            // Add ContractId to RentPayments
            migrationBuilder.Sql(@"
                SET @col_exists = (SELECT COUNT(*) FROM information_schema.COLUMNS
                    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'RentPayments' AND COLUMN_NAME = 'ContractId');
                SET @stmt = IF(@col_exists = 0,
                    'ALTER TABLE `RentPayments` ADD COLUMN `ContractId` char(36) NULL',
                    'SELECT 1');
                PREPARE s FROM @stmt; EXECUTE s; DEALLOCATE PREPARE s;
            ");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {

        }
    }
}
