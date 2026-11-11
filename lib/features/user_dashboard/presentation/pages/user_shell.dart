import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/theme/responsive.dart';
import '../../../../core/widgets/sidebar_navigation.dart';
import '../../../../firebase_bootstrap.dart';
import '../../../../services/mock_data_service.dart';

class UserShell extends ConsumerWidget {
  final Widget child;

  const UserShell({super.key, required this.child});

  static const List<SidebarItem> _navItems = [
    SidebarItem(label: 'Overview', icon: Icons.dashboard_outlined, route: '/dashboard'),
    SidebarItem(label: 'My CVs', icon: Icons.description_outlined, route: '/dashboard/my-cvs'),
    SidebarItem(label: 'Create CV', icon: Icons.post_add_outlined, route: '/dashboard/create-cv'),
    SidebarItem(label: 'Portfolios', icon: Icons.badge_outlined, route: '/dashboard/portfolios'),
    SidebarItem(label: 'Position Search', icon: Icons.search_outlined, route: '/dashboard/search'),
    SidebarItem(label: 'Notifications', icon: Icons.notifications_none_outlined, route: '/dashboard/notifications'),
  ];

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location == '/dashboard') return 0;
    if (location.startsWith('/dashboard/my-cvs') || location.startsWith('/dashboard/cv/')) return 1;
    if (location.startsWith('/dashboard/create-cv')) return 2;
    if (location.startsWith('/dashboard/portfolios')) return 3;
    if (location.startsWith('/dashboard/search')) return 4;
    if (location.startsWith('/dashboard/notifications')) return 5;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final unreadCount = ref.watch(unreadNotificationCountProvider);
    final selectedIndex = _calculateSelectedIndex(context);
    final isMobile = Responsive.isMobile(context);

    // Update notification badge on the fly
    final items = List<SidebarItem>.from(_navItems);
    items[5] = SidebarItem(
      label: 'Notifications',
      icon: Icons.notifications_none_outlined,
      route: '/dashboard/notifications',
      badgeCount: unreadCount,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: isMobile
          ? Drawer(
              child: SidebarNavigation(
                items: items,
                selectedIndex: selectedIndex,
                onItemSelected: (index) {
                  Navigator.of(context).pop();
                  context.go(items[index].route);
                },
                userName: user?.displayName ?? 'User',
                userEmail: user?.email ?? '',
                userRole: user?.role ?? 'user',
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
              Text('ProCV', style: AppTextStyles.heading4.copyWith(color: AppColors.primary)),
            if (!isMobile)
              Text(
                'Candidate Portal',
                style: AppTextStyles.labelLarge.copyWith(color: AppColors.textSecondary),
              ),
          ],
        ),
        actions: [
          // Role switch badge for demo
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(radius: 4, backgroundColor: AppColors.secondary),
                const SizedBox(width: 6),
                Text('User Role', style: AppTextStyles.labelSmall.copyWith(color: AppColors.secondary)),
              ],
            ),
          ),
          const SizedBox(width: 8),

          IconButton(
            icon: Badge(
              isLabelVisible: unreadCount > 0,
              label: Text('$unreadCount'),
              child: const Icon(Icons.notifications_none_outlined),
            ),
            onPressed: () => context.go('/dashboard/notifications'),
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
                    backgroundColor: AppColors.accent,
                    child: Text(
                      user?.displayName.isNotEmpty == true ? user!.displayName[0].toUpperCase() : 'U',
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (!isMobile) ...[
                    const SizedBox(width: 8),
                    Text(user?.displayName ?? 'User', style: AppTextStyles.labelMedium),
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
              } else if (value == 'switch_dev') {
                ref.read(currentUserProvider.notifier).state = MockDataService.users.firstWhere((u) => u.role == 'developer');
                context.go('/developer');
              } else if (value == 'switch_admin') {
                ref.read(currentUserProvider.notifier).state = MockDataService.users.firstWhere((u) => u.role == 'admin');
                context.go('/admin');
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: Text('Logged in as ${user?.email}', style: AppTextStyles.caption),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'switch_dev',
                child: Row(
                  children: [
                    Icon(Icons.code, size: 18),
                    SizedBox(width: 8),
                    Text('Switch to Developer Dashboard'),
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
              items: items,
              selectedIndex: selectedIndex,
              onItemSelected: (index) => context.go(items[index].route),
              userName: user?.displayName ?? 'User',
              userEmail: user?.email ?? '',
              userRole: user?.role ?? 'user',
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

