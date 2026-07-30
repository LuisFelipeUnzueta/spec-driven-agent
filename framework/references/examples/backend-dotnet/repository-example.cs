using Microsoft.EntityFrameworkCore;
using YourProject.Domain;
using YourProject.Common;

namespace YourProject.Infrastructure.Repositories;

public interface IUserRepository
{
    Task<Result<User>> SaveAsync(User user, CancellationToken ct);
    Task<Result<User>> FindByIdAsync(string id, CancellationToken ct);
}

public sealed class UserRepository : IUserRepository
{
    private readonly AppDbContext _db;

    public UserRepository(AppDbContext db)
    {
        _db = db;
    }

    public async Task<Result<User>> SaveAsync(User user, CancellationToken ct)
    {
        try
        {
            _db.Users.Add(user);
            await _db.SaveChangesAsync(ct);
            return Result<User>.Success(user);
        }
        catch (DbUpdateException ex) when (ex.InnerException?.Message.Contains("duplicate") == true)
        {
            return Result<User>.Failure("Email already exists");
        }
    }

    public async Task<Result<User>> FindByIdAsync(string id, CancellationToken ct)
    {
        var user = await _db.Users.FirstOrDefaultAsync(u => u.Id == id, ct);
        return user is not null
            ? Result<User>.Success(user)
            : Result<User>.Failure("User not found");
    }
}
