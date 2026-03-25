using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;
using Microsoft.Extensions.Configuration;

namespace Ijari.Infrastructure.Data;

public class AppDbContextFactory : IDesignTimeDbContextFactory<AppDbContext>
{
    public AppDbContext CreateDbContext(string[] args)
    {
        var config = new ConfigurationBuilder()
            .SetBasePath(Path.Combine(Directory.GetCurrentDirectory(), "../Ijari.Api"))
            .AddJsonFile("appsettings.json")
            .Build();

        var opts = new DbContextOptionsBuilder<AppDbContext>();
        opts.UseNpgsql(config.GetConnectionString("Default"));
        return new AppDbContext(opts.Options);
    }
}
