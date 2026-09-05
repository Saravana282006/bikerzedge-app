import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../data/models/user.dart';

/// A circular initials avatar for a staff member.
class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.user, this.size = 40});

  final AppUser user;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = user.isAdmin ? AppColors.ink : AppColors.brandOrangeDark;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        user.initials,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.36,
        ),
      ),
    );
  }
}
