import { Result } from '../common/result';
import { User } from '../domain/user';
import { AppDataSource } from '../config/database';

export interface IUserRepository {
  save(user: User): Promise<Result<User>>;
  findById(id: string): Promise<Result<User>>;
}

export class UserRepository implements IUserRepository {
  async save(user: User): Promise<Result<User>> {
    try {
      await AppDataSource.getRepository(User).save(user);
      return Result.ok(user);
    } catch (err: any) {
      if (err.code === '23505') {
        return Result.fail('Email already exists');
      }
      return Result.fail(`Failed to save user: ${err.message}`);
    }
  }

  async findById(id: string): Promise<Result<User>> {
    const user = await AppDataSource.getRepository(User).findOneBy({ id });
    if (!user) return Result.fail('User not found');
    return Result.ok(user);
  }
}
