using Ijari.Core.Interfaces;
using MailKit.Net.Smtp;
using MailKit.Security;
using Microsoft.Extensions.Configuration;
using MimeKit;

namespace Ijari.Infrastructure.Services;

public class EmailService : IEmailService
{
    private readonly IConfiguration _config;

    public EmailService(IConfiguration config)
    {
        _config = config;
    }

    public async Task SendAsync(string toEmail, string toName, string subject, string htmlBody)
    {
        var from = _config["Email:From"] ?? "noreply@ijari.app";
        var fromName = _config["Email:FromName"] ?? "Ijari";

        var message = new MimeMessage();
        message.From.Add(new MailboxAddress(fromName, from));
        message.To.Add(new MailboxAddress(toName, toEmail));
        message.Subject = subject;

        var body = new BodyBuilder { HtmlBody = htmlBody };
        message.Body = body.ToMessageBody();

        using var client = new SmtpClient();
        await client.ConnectAsync(
            _config["Email:SmtpHost"] ?? "localhost",
            int.Parse(_config["Email:SmtpPort"] ?? "1025"),
            SecureSocketOptions.None);

        var user = _config["Email:SmtpUser"];
        var pass = _config["Email:SmtpPass"];
        if (!string.IsNullOrEmpty(user))
            await client.AuthenticateAsync(user, pass);

        await client.SendAsync(message);
        await client.DisconnectAsync(true);
    }
}
