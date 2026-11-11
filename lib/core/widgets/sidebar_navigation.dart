import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../theme/responsive.dart';

/// Sidebar navigation item data
class SidebarItem {
  final String label;
  final IconData icon;
  final String route;
  final int? badgeCount;

  const SidebarItem({
    required this.label,
    required this.icon,
    required this.route,
    this.badgeCount,
  });
}

/// Modern sidebar navigation widget with collapsed/expanded states
class SidebarNavigation extends StatelessWidget {
  final List<SidebarItem> items;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final String userName;
  final String userEmail;
  final String userRole;
  final String? userAvatarUrl;
  final VoidCallback? onLogout;

  const SidebarNavigation({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.userName,
    required this.userEmail,
    required this.userRole,
    this.userAvatarUrl,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final isExpanded = Responsive.showExpandedSidebar(context);
    final isCollapsed = Responsive.showCollapsedSidebar(context);

    if (!isExpanded && !isCollapsed) return const SizedBox.shrink();

    return Container(
      width: isExpanded ? 260 : 72,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
      ),
      child: Column(
        children: [
          // Logo / Brand
          _buildHeader(isExpanded),
          const SizedBox(height: 8),

          // Navigation items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return _buildNavItem(
                  context,
                  items[index],
                  isSelected: index == selectedIndex,
                  isExpanded: isExpanded,
                  onTap: () => onItemSelected(index),
                ).animate(delay: Duration(milliseconds: 50 * index)).fadeIn(
                      duration: 300.ms,
                    );
              },
            ),
          ),

          // User info & logout
          _buildFooter(context, isExpanded),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isExpanded) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isExpanded ? 24 : 16,
        vertical: 24,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: AppColors.accentGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text(
                'P',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          if (isExpanded) ...[
            const SizedBox(width: 12),
            Text(
              'ProCV',
              style: AppTextStyles.heading4.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    SidebarItem item, {
    required bool isSelected,
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          hoverColor: AppColors.sidebarItemHover,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: isExpanded ? 16 : 0,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.sidebarItemActive.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(
                      color: AppColors.sidebarItemActive.withValues(alpha: 0.3),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              mainAxisAlignment:
                  isExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      item.icon,
                      size: 20,
                      color: isSelected
                          ? AppColors.sidebarTextActive
                          : AppColors.sidebarText,
                    ),
                    if (item.badgeCount != null && item.badgeCount! > 0)
                      Positioned(
                        top: -6,
                        right: -8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${item.badgeCount}',
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                if (isExpanded) ...[
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      item.label,
                      style: isSelected
                          ? AppTextStyles.sidebarItemActive
                          : AppTextStyles.sidebarItem,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, bool isExpanded) {
    return Container(
      padding: EdgeInsets.all(isExpanded ? 16 : 12),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFF1E293B), width: 1),
        ),
      ),
      child: Column(
        children: [
          if (isExpanded)
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.accent,
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        userRole.toUpperCase(),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.sidebarText,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onLogout,
                  icon: const Icon(
                    Icons.logout_rounded,
                    size: 18,
                    color: AppColors.sidebarText,
                  ),
                  tooltip: 'Logout',
                ),
              ],
            )
          else
            IconButton(
              onPressed: onLogout,
              icon: const Icon(
                Icons.logout_rounded,
                size: 20,
                color: AppColors.sidebarText,
              ),
              tooltip: 'Logout',
            ),
        ],
      ),
    );
  }
}

