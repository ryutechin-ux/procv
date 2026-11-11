import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/theme/responsive.dart';
import '../../../../features/notifications/data/models/notification_model.dart';
import '../../../../firebase_bootstrap.dart';
import '../../../../services/mock_data_service.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  bool _showUnreadOnly = false;

  Future<void> _markAllAsRead() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    try {
      if (firebaseConfigured) {
        await ref.read(firebaseRepositoryProvider).markAllRead(user.uid);
      } else {
        setState(() {
          for (int i = 0; i < MockDataService.notifications.length; i++) {
            if (MockDataService.notifications[i].userId == user.uid) {
              MockDataService.notifications[i] = MockDataService.notifications[i].copyWith(isRead: true);
            }
          }
        });
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All notifications marked as read')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          content: Text(firebaseErrorMessage(e)),
        ),
      );
    }
  }

  Future<void> _markSingleRead(NotificationModel notif) async {
    try {
      if (firebaseConfigured) {
        await ref.read(firebaseRepositoryProvider).markNotificationRead(notif.id);
      } else {
        setState(() {
          final idx = MockDataService.notifications.indexWhere((n) => n.id == notif.id);
          if (idx != -1) {
            MockDataService.notifications[idx] = notif.copyWith(isRead: true);
          }
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final userNotifs = ref.watch(userNotificationsProvider);
    final filtered = _showUnreadOnly ? userNotifs.where((n) => !n.isRead).toList() : userNotifs;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.contentPadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Notification Center', style: AppTextStyles.heading2),
                    const SizedBox(height: 4),
                    Text(
                      'Real-time alerts regarding CV submissions, assignment milestones, and admin quality approvals.',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('Unread Only'),
                      selected: _showUnreadOnly,
                      onSelected: (val) => setState(() => _showUnreadOnly = val),
                    ),
                    ElevatedButton.icon(
                      onPressed: userNotifs.any((n) => !n.isRead) ? _markAllAsRead : null,
                      icon: const Icon(Icons.done_all, size: 16),
                      label: const Text('Mark All as Read'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            if (filtered.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(48),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.notifications_off_outlined, size: 54, color: AppColors.textTertiary),
                        const SizedBox(height: 16),
                        Text('No notifications to display', style: AppTextStyles.heading4),
                        const SizedBox(height: 6),
                        Text('You are completely up to date.', style: AppTextStyles.bodyMedium),
                      ],
                    ),
                  ),
                ),
              )
            else
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    separatorBuilder: (context, _) => const Divider(height: 16),
                    itemBuilder: (context, index) {
                      final n = filtered[index];
                      return ListTile(
                        onTap: () {
                          _markSingleRead(n);
                          if (n.relatedRequestId != null) {
                            final userRole = ref.read(currentUserRoleProvider);
                            if (userRole == 'user') {
                              context.go('/dashboard/cv/${n.relatedRequestId}');
                            } else if (userRole == 'developer') {
                              context.go('/developer/assigned-works');
                            } else {
                              context.go('/admin/review');
                            }
                          }
                        },
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: n.isRead
                                ? AppColors.surfaceVariant
                                : AppColors.accent.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _iconForType(n.type),
                            color: n.isRead ? AppColors.textTertiary : AppColors.accent,
                            size: 22,
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(
                              n.title,
                              style: AppTextStyles.labelLarge.copyWith(
                                fontWeight: n.isRead ? FontWeight.normal : FontWeight.bold,
                              ),
                            ),
                            if (!n.isRead) ...[
                              const SizedBox(width: 8),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.accent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(n.message, style: AppTextStyles.bodySmall),
                            const SizedBox(height: 4),
                            Text(
                              '${n.createdAt.day}/${n.createdAt.month}/${n.createdAt.year} • Type: ${n.type}',
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                        trailing: n.relatedRequestId != null
                            ? const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textTertiary)
                            : null,
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'CV_APPROVED':
        return Icons.verified;
      case 'CV_ASSIGNED':
      case 'NEW_WORK_ASSIGNED':
        return Icons.assignment_ind;
      case 'CV_IN_PROGRESS':
        return Icons.engineering;
      case 'REVISION_REQUESTED':
      case 'CV_REVISION_REQUIRED':
        return Icons.warning_amber_rounded;
      case 'NEW_CV_REQUEST':
        return Icons.post_add;
      default:
        return Icons.notifications;
    }
  }
}

