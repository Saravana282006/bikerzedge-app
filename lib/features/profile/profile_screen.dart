import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/common.dart';
import '../../widgets/user_avatar.dart';
import '../shell/app_shell.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthBloc>().state.user!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [NotificationAction(user: user), const SizedBox(width: 4)],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                UserAvatar(user: user, size: 84),
                const SizedBox(height: 14),
                Text(user.name,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: (user.isAdmin
                            ? AppColors.ink
                            : AppColors.brandOrangeDark)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    user.role.label,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                      color: user.isAdmin
                          ? AppColors.ink
                          : AppColors.brandOrangeDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          const SectionHeader('Account'),
          PanelCard(
            child: Column(
              children: [
                InfoRow(
                    label: 'Email',
                    value: user.email,
                    icon: Icons.mail_outline),
                if (user.phone != null)
                  InfoRow(
                      label: 'Phone',
                      value: user.phone!,
                      icon: Icons.phone_outlined),
                InfoRow(
                    label: 'Role',
                    value: user.role.label,
                    icon: Icons.badge_outlined),
                InfoRow(
                  label: 'Status',
                  value: user.active ? 'Active' : 'Inactive',
                  icon: Icons.check_circle_outline,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const SectionHeader('Permissions'),
          PanelCard(
            child: Column(
              children: user.isAdmin
                  ? _perms(const [
                      'Create, edit and assign jobs',
                      'Update any job status',
                      'Close completed jobs',
                      'View all jobs and reports',
                      'Manage mechanics',
                    ])
                  : _perms(const [
                      'View jobs assigned to you',
                      'Update status of your jobs',
                      'Add diagnosis, notes & photos',
                      'Record spare parts used',
                    ]),
            ),
          ),
          const SizedBox(height: 20),
          const SectionHeader('About'),
          const PanelCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('MotoTrack — Workshop Job Tracker',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                SizedBox(height: 4),
                Text(
                  'Internal app for BIKERZEDGE. Interactive prototype '
                  'v1.0 (mock data). Built with Flutter + Bloc.',
                  style: TextStyle(
                      fontSize: 12.5, color: AppColors.slate500, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () => _confirmSignOut(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                side: const BorderSide(color: AppColors.danger),
              ),
              icon: const Icon(Icons.logout),
              label: const Text('Sign out'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  List<Widget> _perms(List<String> items) {
    return [
      for (final p in items)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              const Icon(Icons.check, size: 17, color: AppColors.success),
              const SizedBox(width: 10),
              Expanded(
                child: Text(p, style: const TextStyle(fontSize: 13.5)),
              ),
            ],
          ),
        ),
    ];
  }

  void _confirmSignOut(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You will return to the login screen.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      context.read<AuthBloc>().add(const AuthSignOutRequested());
    }
  }
}
