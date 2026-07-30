import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/user.dart';
import '../../infrastructure/repositories/user_repository.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository _userRepository;

  UserBloc({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(const UserInitial()) {
    on<LoadUsers>(_onLoadUsers);
    on<CreateUser>(_onCreateUser);
  }

  Future<void> _onLoadUsers(LoadUsers event, Emitter<UserState> emit) async {
    emit(const UserLoading());
    final result = await _userRepository.findAll();
    result.fold(
      (failure) => emit(UserError(failure.message)),
      (users) => emit(UsersLoaded(users)),
    );
  }

  Future<void> _onCreateUser(CreateUser event, Emitter<UserState> emit) async {
    emit(const UserLoading());
    final user = User(name: event.name, email: event.email);
    final result = await _userRepository.save(user);
    result.fold(
      (failure) => emit(UserError(failure.message)),
      (_) => add(const LoadUsers()),
    );
  }
}
