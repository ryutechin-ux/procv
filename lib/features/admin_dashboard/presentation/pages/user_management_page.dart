import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/theme/responsive.dart';
import '../../../../features/auth/data/models/user_model.dart';
import '../../../../firebase_bootstrap.dart';
import '../../../../services/mock_data_service.dart';

class UserManagementPage extends ConsumerStatefulWidget {
  const UserManagementPage({super.key});

  @override
  ConsumerState<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends ConsumerState<UserManagementPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(allUsersProvider);
    final allCvs = ref.watch(allCvRequestsProvider);

    final filteredUsers = users.where((u) {
      final query = _searchQuery.toLowerCase();
      return u.displayName.toLowerCase().contains(query) ||
          u.email.toLowerCase().contains(query) ||
          (u.location?.toLowerCase().contains(query) ?? false);
    }).toList();

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
                    Text('User Management', style: AppTextStyles.heading2),
                    const SizedBox(height: 4),
                    Text(
                      'View all registered candidates, review submission history, and manage account statuses.',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Search Filter
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: const InputDecoration(
                    hintText: 'Search by candidate name, email, or location...',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // User Table / Cards
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Registered Candidates (${filteredUsers.length})', style: AppTextStyles.heading4),
                    const SizedBox(height: 16),
                    if (filteredUsers.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: Text('No users match search criteria')),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredUsers.length,
                        separatorBuilder: (context, _) => const Divider(height: 24),
                        itemBuilder: (context, index) {
                          final user = filteredUsers[index];
                          final userCvs = allCvs.where((c) => c.userId == user.uid).toList();

                          return Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: AppColors.accent.withValues(alpha: 0.1),
                                child: Text(
                                  user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : 'U',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accent, fontSize: 16),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(user.displayName, style: AppTextStyles.labelLarge),
                                        if (user.isBlocked) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.errorLight,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Text('BLOCKED', style: TextStyle(fontSize: 10, color: AppColors.error, fontWeight: FontWeight.bold)),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text('${user.email} • ${user.phone ?? "No phone"} • ${user.location ?? "No location"}', style: AppTextStyles.bodySmall),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text('Total CVs: ${userCvs.length}', style: AppTextStyles.bodyMedium),
                              ),
                              Wrap(
                                spacing: 8,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () => _showUserHistoryDialog(context, user, userCvs),
                                    icon: const Icon(Icons.history, size: 16),
                                    label: const Text('CV History'),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: () async {
                                      final nextBlockedState = !user.isBlocked;
                                      try {
                                        if (firebaseConfigured) {
                                          await ref.read(firebaseRepositoryProvider).setUserBlocked(user.uid, nextBlockedState);
                                        } else {
                                          setState(() {
                                            final idx = MockDataService.users.indexWhere((u) => u.uid == user.uid);
                                            if (idx != -1) {
                                              MockDataService.users[idx] = user.copyWith(isBlocked: nextBlockedState);
                                            }
                                          });
                                        }
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(nextBlockedState ? 'User blocked' : 'User unblocked'),
                                          ),
                                        );
                                      } catch (e) {
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            backgroundColor: AppColors.error,
                                            content: Text(firebaseErrorMessage(e)),
                                          ),
                                        );
                                      }
                                    },
                                    icon: Icon(user.isBlocked ? Icons.lock_open : Icons.block, size: 16, color: user.isBlocked ? AppColors.success : AppColors.error),
                                    label: Text(
                                      user.isBlocked ? 'Unblock' : 'Block',
                                      style: TextStyle(color: user.isBlocked ? AppColors.success : AppColors.error),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUserHistoryDialog(BuildContext context, UserModel user, List userCvs) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('${user.displayName} – CV History'),
        content: SizedBox(
          width: 500,
          child: userCvs.isEmpty
              ? const Text('This candidate has not created any CV requests yet.')
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: userCvs.length,
                  separatorBuilder: (context, _) => const Divider(),
                  itemBuilder: (context, index) {
                    final cv = userCvs[index];
                    return ListTile(
                      title: Text(cv.title, style: AppTextStyles.labelLarge),
                      subtitle: Text('Target: ${cv.position} • Status: ${cv.status}'),
                      trailing: Text('${cv.createdAt.day}/${cv.createdAt.month}/${cv.createdAt.year}'),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }
}

