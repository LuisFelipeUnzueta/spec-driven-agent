import { Request, Response } from 'express';
import { Result } from '../common/result';
import { UserRepository } from '../repositories/user.repository';
import { User } from '../domain/user';
import { logger } from '../common/logger';

interface CreateUserRequest {
  name: string;
  email: string;
}

interface CreateUserResponse {
  id: string;
  name: string;
  email: string;
}

export class CreateUserHandler {
  constructor(private readonly userRepo: UserRepository) {}

  async handle(req: Request): Promise<Result<CreateUserResponse>> {
    const { name, email } = req.body as CreateUserRequest;

    if (!name) return Result.fail('Name is required');
    if (!email) return Result.fail('Email is required');

    const user = User.create(name, email);
    const saved = await this.userRepo.save(user);
    if (saved.isFailure) return Result.fail(saved.error);

    logger.info('User created', { userId: saved.value.id });
    return Result.ok({
      id: saved.value.id,
      name: saved.value.name,
      email: saved.value.email,
    });
  }
}

export function createUserHandler(userRepo: UserRepository) {
  return async (req: Request, res: Response) => {
    const handler = new CreateUserHandler(userRepo);
    const result = await handler.handle(req);
    if (result.isSuccess) {
      res.status(201).json(result.value);
    } else {
      res.status(400).json({ error: result.error });
    }
  };
}
