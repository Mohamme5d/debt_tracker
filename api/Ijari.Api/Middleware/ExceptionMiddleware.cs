using System.Net;
using System.Text.Json;

namespace Ijari.Api.Middleware;

public class ExceptionMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<ExceptionMiddleware> _logger;
    private readonly IHostEnvironment _env;

    public ExceptionMiddleware(RequestDelegate next, ILogger<ExceptionMiddleware> logger, IHostEnvironment env)
    {
        _next = next;
        _logger = logger;
        _env = env;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch (KeyNotFoundException ex)
        {
            await WriteError(context, HttpStatusCode.NotFound, ex.Message);
        }
        catch (UnauthorizedAccessException ex)
        {
            await WriteError(context, HttpStatusCode.Forbidden, ex.Message);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex,
                "Unhandled exception | {Method} {Path} | User: {User} | IP: {IP}",
                context.Request.Method,
                context.Request.Path,
                context.User?.Identity?.Name ?? "anonymous",
                context.Connection.RemoteIpAddress?.ToString() ?? "unknown");

            var message = _env.IsDevelopment()
                ? $"{ex.GetType().Name}: {ex.Message}"
                : "An internal error occurred. Check server logs for details.";

            await WriteError(context, HttpStatusCode.InternalServerError, message);
        }
    }

    private static Task WriteError(HttpContext context, HttpStatusCode status, string message)
    {
        context.Response.StatusCode  = (int)status;
        context.Response.ContentType = "application/json";
        return context.Response.WriteAsync(JsonSerializer.Serialize(new { message }));
    }
}
