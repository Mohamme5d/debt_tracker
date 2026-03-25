namespace Ijari.Core.Interfaces;

public interface ICurrentTenant
{
    Guid Id { get; }
    Guid UserId { get; }
    string Role { get; }
    string Email { get; }
    bool IsOwner { get; }
    bool IsSuperAdmin { get; }
}
