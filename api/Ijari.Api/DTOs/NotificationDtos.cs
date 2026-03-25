namespace Ijari.Api.DTOs;

public record NotificationResponse(Guid Id, string Title, string Body, bool IsRead, string? EntityType, Guid? EntityId, DateTime CreatedAt);
