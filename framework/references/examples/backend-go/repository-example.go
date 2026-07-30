package repository

import (
	"context"
	"database/sql"
	"errors"
	"fmt"

	"your-project/internal/domain"
)

type UserRepository struct {
	db *sql.DB
}

func NewUserRepository(db *sql.DB) *UserRepository {
	return &UserRepository{db: db}
}

func (r *UserRepository) Save(ctx context.Context, user *domain.User) error {
	const query = `INSERT INTO users (id, name, email, created_at) VALUES ($1, $2, $3, $4)`

	_, err := r.db.ExecContext(ctx, query, user.ID, user.Name, user.Email, user.CreatedAt)
	if err != nil {
		if isDuplicateKey(err) {
			return fmt.Errorf("save user: %w", domain.ErrDuplicateEmail)
		}
		return fmt.Errorf("save user: %w", err)
	}
	return nil
}

func (r *UserRepository) FindByID(ctx context.Context, id string) (*domain.User, error) {
	const query = `SELECT id, name, email, created_at FROM users WHERE id = $1`

	row := r.db.QueryRowContext(ctx, query, id)
	var user domain.User
	if err := row.Scan(&user.ID, &user.Name, &user.Email, &user.CreatedAt); err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, domain.ErrUserNotFound
		}
		return nil, fmt.Errorf("find user by id: %w", err)
	}
	return &user, nil
}

func isDuplicateKey(err error) bool {
	return err != nil && (errors.Is(err, sql.ErrNoRows) == false)
}
