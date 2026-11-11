import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/theme/responsive.dart';
import '../../../../core/widgets/sidebar_navigation.dart';
import '../../../../firebase_bootstrap.dart';
import '../../../../services/mock_data_service.dart';

class AdminShell extends ConsumerWidget {
  final Widget child;

  const AdminShell({super.key, required this.child});

  static const List<SidebarItem> _navItems = [
    SidebarItem(label: 'Dashboard', icon: Icons.dashboard_outlined, route: '/admin'),
    SidebarItem(label: 'CV Requests', icon: Icons.description_outlined, route: '/admin/cv-requests'),
    SidebarItem(label: 'Work Assignment', icon: Icons.assignment_ind_outlined, route: '/admin/assign-work'),
    SidebarItem(label: 'CV Approvals', icon: Icons.rate_review_outlined, route: '/admin/review'),
    SidebarItem(label: 'User Management', icon: Icons.people_outline, route: '/admin/users'),
    SidebarItem(label: 'Developer Team', icon: Icons.engineering_outlined, route: '/admin/developers'),
    SidebarItem(label: 'Notifications', icon: Icons.notifications_none_outlined, route: '/admin/notifications'),
  ];

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location == '/admin') return 0;
    if (location.startsWith('/admin/cv-requests')) return 1;
    if (location.startsWith('/admin/assign-work')) return 2;
    if (location.startsWith('/admin/review')) return 3;
    if (location.startsWith('/admin/users')) return 4;
    if (location.startsWith('/admin/developers')) return 5;
    if (location.startsWith('/admin/notifications')) return 6;
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
                userName: user?.displayName ?? 'Admin',
                userEmail: user?.email ?? '',
                userRole: user?.role ?? 'admin',
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
                'HR & Operations Administration Console',
                style: AppTextStyles.labelLarge.copyWith(color: AppColors.primaryLight),
              ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(radius: 4, backgroundColor: AppColors.primary),
                const SizedBox(width: 6),
                Text('Admin Role', style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary)),
              ],
            ),
          ),
          const SizedBox(width: 8),

          IconButton(
            icon: const Icon(Icons.notifications_none_outlined),
            onPressed: () => context.go('/admin/notifications'),
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
                    backgroundColor: AppColors.primary,
                    child: Text(
                      user?.displayName.isNotEmpty == true ? user!.displayName[0].toUpperCase() : 'A',
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (!isMobile) ...[
                    const SizedBox(width: 8),
                    Text(user?.displayName ?? 'Admin', style: AppTextStyles.labelMedium),
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
                ref.read(currentUserProvider.notifier).state = MockDataService.users.firstWhere((u) => u.role == 'user');
                context.go('/dashboard');
              } else if (value == 'switch_dev') {
                ref.read(currentUserProvider.notifier).state = MockDataService.users.firstWhere((u) => u.role == 'developer');
                context.go('/developer');
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: Text('Logged in as ${user?.email}', style: AppTextStyles.caption),
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
                value: 'switch_dev',
                child: Row(
                  children: [
                    Icon(Icons.code, size: 18),
                    SizedBox(width: 8),
                    Text('Switch to Developer Dashboard'),
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
              userName: user?.displayName ?? 'Admin',
              userEmail: user?.email ?? '',
              userRole: user?.role ?? 'admin',
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

