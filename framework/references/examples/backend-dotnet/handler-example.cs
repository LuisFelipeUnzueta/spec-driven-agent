using YourProject.Domain;
using YourProject.Common;

namespace YourProject.Features.Users.Create;

public sealed record CreateUserCommand(string Name, string Email);

public sealed record CreateUserResponse(string Id, string Name, string Email);

public interface ICreateUserHandler
{
    Task<Result<CreateUserResponse>> Handle(CreateUserCommand command, CancellationToken ct);
}

public sealed class CreateUserHandler : ICreateUserHandler
{
    private readonly IUserRepository _userRepo;
    private readonly ILogger<CreateUserHandler> _logger;

    public CreateUserHandler(IUserRepository userRepo, ILogger<CreateUserHandler> logger)
    {
        _userRepo = userRepo;
        _logger = logger;
    }

    public async Task<Result<CreateUserResponse>> Handle(CreateUserCommand command, CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(command.Name))
            return Result<CreateUserResponse>.Failure("Name is required");

        if (string.IsNullOrWhiteSpace(command.Email))
            return Result<CreateUserResponse>.Failure("Email is required");

        var userResult = User.Create(command.Name, command.Email);
        if (userResult.IsFailure)
            return Result<CreateUserResponse>.Failure(userResult.Error);

        var user = userResult.Value;
        var saveResult = await _userRepo.SaveAsync(user, ct);
        if (saveResult.IsFailure)
            return Result<CreateUserResponse>.Failure(saveResult.Error);

        _logger.LogInformation("User created: {UserId}", user.Id);

        return Result<CreateUserResponse>.Success(new CreateUserResponse(
            user.Id, user.Name, user.Email));
    }
}
