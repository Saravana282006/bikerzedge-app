import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/user.dart';
import '../../data/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._authRepository) : super(const AuthState()) {
    on<AuthSignInRequested>(_onSignIn);
    on<AuthDemoLoginRequested>(_onDemoLogin);
    on<AuthSignOutRequested>(_onSignOut);
  }

  final AuthRepository _authRepository;

  Future<void> _onSignIn(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.authenticating, clearError: true));
    try {
      final user = await _authRepository.signIn(
        email: event.email,
        password: event.password,
      );
      emit(AuthState(status: AuthStatus.authenticated, user: user));
    } on AuthException catch (e) {
      emit(AuthState(status: AuthStatus.failure, error: e.message));
    } catch (_) {
      emit(const AuthState(
        status: AuthStatus.failure,
        error: 'Something went wrong. Please try again.',
      ));
    }
  }

  Future<void> _onDemoLogin(
    AuthDemoLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.authenticating, clearError: true));
    final user = await _authRepository.demoSignIn(event.user);
    emit(AuthState(status: AuthStatus.authenticated, user: user));
  }

  Future<void> _onSignOut(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.signOut();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
