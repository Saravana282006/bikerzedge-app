import '../models/user.dart';
import 'mock_data.dart';

/// Authentication failure surfaced to the UI.
class AuthException implements Exception {
  const AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Prototype auth backed by the seeded user list.
///
/// Any password is accepted for a known, active email — this is a demo. The
/// interface mirrors what a Firebase Authentication implementation would
/// expose, so it can be swapped in later without touching the Bloc layer.
class AuthRepository {
  AppUser? _current;

  AppUser? get currentUser => _current;

  /// Sign in with email + password. In the prototype the password is not
  /// checked; the email must match a known active staff account.
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    final normalized = email.trim().toLowerCase();
    final match = MockData.users().where(
      (u) => u.email.toLowerCase() == normalized,
    );

    if (match.isEmpty) {
      throw const AuthException('No staff account found for that email.');
    }
    final user = match.first;
    if (!user.active) {
      throw const AuthException(
        'This account is inactive. Contact the workshop admin.',
      );
    }
    if (password.trim().isEmpty) {
      throw const AuthException('Please enter your password.');
    }
    _current = user;
    return user;
  }

  /// One-tap demo login used by the login screen's quick-access buttons.
  Future<AppUser> demoSignIn(AppUser user) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _current = user;
    return user;
  }

  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    _current = null;
  }
}
