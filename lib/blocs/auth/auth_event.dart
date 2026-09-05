part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

/// Sign in with typed email + password.
class AuthSignInRequested extends AuthEvent {
  const AuthSignInRequested({required this.email, required this.password});
  final String email;
  final String password;
  @override
  List<Object?> get props => [email, password];
}

/// One-tap demo login for the prototype's quick-access buttons.
class AuthDemoLoginRequested extends AuthEvent {
  const AuthDemoLoginRequested(this.user);
  final AppUser user;
  @override
  List<Object?> get props => [user];
}

class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}
