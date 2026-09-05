import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocs/auth/auth_bloc.dart';
import 'blocs/jobs/jobs_bloc.dart';
import 'blocs/notifications/notifications_bloc.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/job_repository.dart';
import 'features/auth/login_screen.dart';
import 'features/shell/app_shell.dart';

/// Root of the MotoTrack prototype. Wires repositories + blocs and swaps the
/// login screen for the role-based shell based on auth state.
class MotoTrackApp extends StatelessWidget {
  const MotoTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => AuthRepository()),
        RepositoryProvider(create: (_) => JobRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (ctx) => AuthBloc(ctx.read<AuthRepository>()),
          ),
          BlocProvider(
            create: (ctx) => JobsBloc(ctx.read<JobRepository>()),
          ),
          BlocProvider(
            create: (ctx) => NotificationsBloc(ctx.read<JobRepository>()),
          ),
        ],
        child: MaterialApp(
          title: 'MotoTrack',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          home: const _Root(),
        ),
      ),
    );
  }
}

class _Root extends StatelessWidget {
  const _Root();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (a, b) => a.isAuthenticated != b.isAuthenticated,
      builder: (context, state) {
        if (state.isAuthenticated) {
          final user = state.user!;
          return ShellBootstrap(
            key: ValueKey('shell_${user.id}'),
            user: user,
            child: AppShell(user: user),
          );
        }
        return const LoginScreen();
      },
    );
  }
}
