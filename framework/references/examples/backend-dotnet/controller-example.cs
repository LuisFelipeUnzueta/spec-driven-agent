using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using YourProject.Features.Users.Create;

namespace YourProject.Api.Controllers;

[ApiController]
[Route("api/users")]
[Authorize(Roles = "write:users")]
public sealed class UsersController : ControllerBase
{
    [HttpPost]
    public async Task<IActionResult> Create(
        [FromBody] CreateUserCommand command,
        [FromServices] ICreateUserHandler handler,
        CancellationToken ct)
    {
        if (command is null)
            return BadRequest("Invalid request");

        var result = await handler.Handle(command, ct);

        return result.IsSuccess
            ? Created($"/api/users/{result.Value.Id}", result.Value)
            : BadRequest(result.Error);
    }
}
