import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/jobs/jobs_bloc.dart';
import '../../blocs/notifications/notifications_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/user.dart';
import '../dashboard/admin_dashboard_screen.dart';
import '../dashboard/mechanic_dashboard_screen.dart';
import '../jobs/create_job_screen.dart';
import '../jobs/jobs_list_screen.dart';
import '../mechanics/mechanics_screen.dart';
import '../notifications/notifications_screen.dart';
import '../profile/profile_screen.dart';
import '../reports/reports_screen.dart';
import '../spare_parts/spare_parts_screen.dart';

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.page,
  });
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final Widget page;
}

/// The main authenticated container: responsive navigation + role-based
/// destinations, with a floating "Create Job" action for admins.
class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.user});

  final AppUser user;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  List<_NavItem> get _items {
    if (widget.user.isAdmin) {
      return const [
        _NavItem(
          icon: Icons.dashboard_outlined,
          selectedIcon: Icons.dashboard,
          label: 'Dashboard',
          page: AdminDashboardScreen(),
        ),
        _NavItem(
          icon: Icons.build_circle_outlined,
          selectedIcon: Icons.build_circle,
          label: 'Jobs',
          page: JobsListScreen(scope: JobsScope.all),
        ),
        _NavItem(
          icon: Icons.insights_outlined,
          selectedIcon: Icons.insights,
          label: 'Reports',
          page: ReportsScreen(),
        ),
        _NavItem(
          icon: Icons.groups_outlined,
          selectedIcon: Icons.groups,
          label: 'Mechanics',
          page: MechanicsScreen(),
        ),
        _NavItem(
          icon: Icons.inventory_2_outlined,
          selectedIcon: Icons.inventory_2,
          label: 'Parts',
          page: SparePartsScreen(),
        ),
        _NavItem(
          icon: Icons.person_outline,
          selectedIcon: Icons.person,
          label: 'Profile',
          page: ProfileScreen(),
        ),
      ];
    }
    return const [
      _NavItem(
        icon: Icons.dashboard_outlined,
        selectedIcon: Icons.dashboard,
        label: 'Dashboard',
        page: MechanicDashboardScreen(),
      ),
      _NavItem(
        icon: Icons.build_circle_outlined,
        selectedIcon: Icons.build_circle,
        label: 'My Jobs',
        page: JobsListScreen(scope: JobsScope.mine),
      ),
      _NavItem(
        icon: Icons.person_outline,
        selectedIcon: Icons.person,
        label: 'Profile',
        page: ProfileScreen(),
      ),
    ];
  }

  void _select(int i) => setState(() => _index = i);

  void _openMoreSheet(List<_NavItem> items) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < items.length; i++)
              ListTile(
                leading: Icon(
                  _index == i ? items[i].selectedIcon : items[i].icon,
                  color: _index == i
                      ? AppColors.brandOrangeDark
                      : AppColors.slate500,
                ),
                title: Text(items[i].label),
                selected: _index == i,
                onTap: () {
                  Navigator.pop(ctx);
                  _select(i);
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    final isWide = MediaQuery.sizeOf(context).width >= 900;
    final body = IndexedStack(
      index: _index,
      children: [for (final it in items) it.page],
    );

    final fab = widget.user.isAdmin
        ? FloatingActionButton.extended(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const CreateJobScreen(),
              ),
            ),
            icon: const Icon(Icons.add),
            label: const Text('New Job'),
          )
        : null;

    if (isWide) {
      return Scaffold(
        floatingActionButton: fab,
        body: SafeArea(
          child: Row(
            children: [
              _SideRail(
                items: items,
                index: _index,
                onSelect: _select,
                user: widget.user,
              ),
              const VerticalDivider(width: 1),
              Expanded(child: body),
            ],
          ),
        ),
      );
    }

    // Phone: bottom navigation. If more than 5 destinations, show the first
    // four and a "More" entry that lists the rest.
    final showMore = items.length > 5;
    final visibleCount = showMore ? 4 : items.length;
    final destinations = <NavigationDestination>[
      for (var i = 0; i < visibleCount; i++)
        NavigationDestination(
          icon: Icon(items[i].icon),
          selectedIcon: Icon(items[i].selectedIcon),
          label: items[i].label,
        ),
      if (showMore)
        const NavigationDestination(
          icon: Icon(Icons.more_horiz),
          label: 'More',
        ),
    ];

    final selectedBottomIndex =
        _index < visibleCount ? _index : (showMore ? visibleCount : _index);

    return Scaffold(
      floatingActionButton: fab,
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedBottomIndex.clamp(0, destinations.length - 1),
        onDestinationSelected: (i) {
          if (showMore && i == visibleCount) {
            _openMoreSheet(items);
          } else {
            _select(i);
          }
        },
        destinations: destinations,
      ),
    );
  }
}

class _SideRail extends StatelessWidget {
  const _SideRail({
    required this.items,
    required this.index,
    required this.onSelect,
    required this.user,
  });

  final List<_NavItem> items;
  final int index;
  final ValueChanged<int> onSelect;
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 16, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppColors.brandOrange,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(Icons.two_wheeler,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                const Text(
                  'MotoTrack',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (var i = 0; i < items.length; i++)
                  _RailTile(
                    item: items[i],
                    selected: i == index,
                    onTap: () => onSelect(i),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.badge_outlined,
                    size: 16, color: AppColors.slate500),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    user.role.label,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.slate500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _NotificationBell(user: user),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RailTile extends StatelessWidget {
  const _RailTile({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Material(
        color: selected
            ? AppColors.brandOrange.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              children: [
                Icon(
                  selected ? item.selectedIcon : item.icon,
                  size: 20,
                  color: selected
                      ? AppColors.brandOrangeDark
                      : AppColors.slate500,
                ),
                const SizedBox(width: 12),
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color:
                        selected ? AppColors.brandOrangeDark : AppColors.slate700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A bell button with an unread badge, shared by rail and app bars.
class _NotificationBell extends StatelessWidget {
  const _NotificationBell({required this.user});
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsBloc, NotificationsState>(
      builder: (context, state) {
        final unread = state.unreadCount;
        return IconButton(
          tooltip: 'Notifications',
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => NotificationsScreen(user: user),
            ),
          ),
          icon: Badge(
            isLabelVisible: unread > 0,
            label: Text('$unread'),
            child: const Icon(Icons.notifications_outlined),
          ),
        );
      },
    );
  }
}

/// A reusable app bar action bell for the phone screens.
class NotificationAction extends StatelessWidget {
  const NotificationAction({super.key, required this.user});
  final AppUser user;

  @override
  Widget build(BuildContext context) => _NotificationBell(user: user);
}

/// Ensures jobs are loaded once the shell mounts.
class ShellBootstrap extends StatefulWidget {
  const ShellBootstrap({super.key, required this.user, required this.child});
  final AppUser user;
  final Widget child;

  @override
  State<ShellBootstrap> createState() => _ShellBootstrapState();
}

class _ShellBootstrapState extends State<ShellBootstrap> {
  @override
  void initState() {
    super.initState();
    context.read<JobsBloc>().add(const JobsLoaded());
    context
        .read<NotificationsBloc>()
        .add(NotificationsLoaded(widget.user.id));
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
