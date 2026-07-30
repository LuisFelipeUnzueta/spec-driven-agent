package handler

import (
	"context"
	"errors"
	"fmt"
	"log/slog"

	"your-project/internal/domain"
	"your-project/pkg/result"
)

type CreateUserRequest struct {
	Name  string `json:"name"`
	Email string `json:"email"`
}

type CreateUserResponse struct {
	ID    string `json:"id"`
	Name  string `json:"name"`
	Email string `json:"email"`
}

type CreateUserHandler struct {
	userRepo domain.UserRepository
	logger   *slog.Logger
}

func NewCreateUserHandler(userRepo domain.UserRepository, logger *slog.Logger) *CreateUserHandler {
	return &CreateUserHandler{userRepo: userRepo, logger: logger}
}

func (h *CreateUserHandler) Handle(ctx context.Context, req CreateUserRequest) result.Result[CreateUserResponse] {
	const op = "handler.CreateUserHandler.Handle"

	if req.Name == "" {
		return result.Fail[CreateUserResponse](fmt.Errorf("%s: nome é obrigatório", op))
	}
	if req.Email == "" {
		return result.Fail[CreateUserResponse](fmt.Errorf("%s: email é obrigatório", op))
	}

	user, err := domain.NewUser(req.Name, req.Email)
	if err != nil {
		return result.Fail[CreateUserResponse](fmt.Errorf("%s: %w", op, err))
	}

	if err := h.userRepo.Save(ctx, user); err != nil {
		if errors.Is(err, domain.ErrDuplicateEmail) {
			return result.Fail[CreateUserResponse](fmt.Errorf("%s: email já cadastrado", op))
		}
		return result.Fail[CreateUserResponse](fmt.Errorf("%s: %w", op, err))
	}

	h.logger.InfoContext(ctx, "usuário criado", "user_id", user.ID, "email", user.Email)

	return result.Ok(CreateUserResponse{
		ID:    user.ID,
		Name:  user.Name,
		Email: user.Email,
	})
}
