namespace Ijari.Api.DTOs;

public record ApprovalRequestResponse(
    Guid Id, string EntityType, Guid EntityId, string Action, string Status,
    string SubmittedByName, string SubmittedByEmail, string? ReviewedByName,
    string? ReviewNotes, DateTime CreatedAt, DateTime? ReviewedAt);

public record ReviewRequest(string? Notes);
