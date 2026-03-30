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
        var cs = config.GetConnectionString("Default")!;
        opts.UseMySql(cs, ServerVersion.AutoDetect(cs));
        return new AppDbContext(opts.Options);
    }
}
