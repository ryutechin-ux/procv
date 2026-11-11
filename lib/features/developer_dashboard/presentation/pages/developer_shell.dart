import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/theme/responsive.dart';
import '../../../../core/widgets/sidebar_navigation.dart';
import '../../../../firebase_bootstrap.dart';
import '../../../../services/mock_data_service.dart';

class DeveloperShell extends ConsumerWidget {
  final Widget child;

  const DeveloperShell({super.key, required this.child});

  static const List<SidebarItem> _navItems = [
    SidebarItem(
      label: 'Overview',
      icon: Icons.dashboard_outlined,
      route: '/developer',
    ),
    SidebarItem(
      label: 'Assigned Works',
      icon: Icons.assignment_outlined,
      route: '/developer/assigned-works',
    ),
    SidebarItem(
      label: 'Notifications',
      icon: Icons.notifications_none_outlined,
      route: '/developer/notifications',
    ),
  ];

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location == '/developer') return 0;
    if (location.startsWith('/developer/assigned-works') ||
        location.startsWith('/developer/work') ||
        location.startsWith('/developer/submit')) {
      return 1;
    }
    if (location.startsWith('/developer/notifications')) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final selectedIndex = _calculateSelectedIndex(context);
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: isMobile
          ? Drawer(
              child: SidebarNavigation(
                items: _navItems,
                selectedIndex: selectedIndex,
                onItemSelected: (index) {
                  Navigator.of(context).pop();
                  context.go(_navItems[index].route);
                },
                userName: user?.displayName ?? 'Developer',
                userEmail: user?.email ?? '',
                userRole: user?.role ?? 'developer',
                onLogout: () {
                  if (firebaseConfigured) {
                    ref.read(firebaseRepositoryProvider).signOut();
                  }
                  ref.read(currentUserProvider.notifier).state = null;
                  context.go('/login');
                },
              ),
            )
          : null,
      appBar: AppBar(
        title: Row(
          children: [
            if (isMobile)
              Text(
                'ProCV',
                style: AppTextStyles.heading4.copyWith(
                  color: AppColors.primary,
                ),
              ),
            if (!isMobile)
              Text(
                'CV Developer Workspace',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.accent,
                ),
              ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 4,
                  backgroundColor: AppColors.accent,
                ),
                const SizedBox(width: 6),
                Text(
                  'Developer Role',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          IconButton(
            icon: const Icon(Icons.notifications_none_outlined),
            onPressed: () => context.go('/developer/notifications'),
            tooltip: 'Notifications',
          ),
          const SizedBox(width: 8),

          PopupMenuButton<String>(
            tooltip: 'Account',
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.accentDark,
                    child: Text(
                      user?.displayName.isNotEmpty == true
                          ? user!.displayName[0].toUpperCase()
                          : 'D',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (!isMobile) ...[
                    const SizedBox(width: 8),
                    Text(
                      user?.displayName ?? 'Developer',
                      style: AppTextStyles.labelMedium,
                    ),
                    const Icon(Icons.keyboard_arrow_down, size: 16),
                  ],
                ],
              ),
            ),
            onSelected: (value) {
              if (value == 'logout') {
                if (firebaseConfigured) {
                  ref.read(firebaseRepositoryProvider).signOut();
                }
                ref.read(currentUserProvider.notifier).state = null;
                context.go('/login');
              } else if (value == 'switch_user') {
                ref.read(currentUserProvider.notifier).state = MockDataService
                    .users
                    .firstWhere((u) => u.role == 'user');
                context.go('/dashboard');
              } else if (value == 'switch_admin') {
                ref.read(currentUserProvider.notifier).state = MockDataService
                    .users
                    .firstWhere((u) => u.role == 'admin');
                context.go('/admin');
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: Text(
                  'Logged in as ${user?.email}',
                  style: AppTextStyles.caption,
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'switch_user',
                child: Row(
                  children: [
                    Icon(Icons.person_outline, size: 18),
                    SizedBox(width: 8),
                    Text('Switch to User Dashboard'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'switch_admin',
                child: Row(
                  children: [
                    Icon(Icons.admin_panel_settings_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('Switch to Admin Dashboard'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 18, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('Logout', style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          if (!isMobile)
            SidebarNavigation(
              items: _navItems,
              selectedIndex: selectedIndex,
              onItemSelected: (index) => context.go(_navItems[index].route),
              userName: user?.displayName ?? 'Developer',
              userEmail: user?.email ?? '',
              userRole: user?.role ?? 'developer',
              onLogout: () {
                ref.read(currentUserProvider.notifier).state = null;
                context.go('/login');
              },
            ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
