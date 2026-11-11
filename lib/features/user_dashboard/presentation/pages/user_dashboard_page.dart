import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/theme/responsive.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../services/mock_data_service.dart';

class UserDashboardPage extends ConsumerWidget {
  const UserDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final userCvs = ref.watch(userCvRequestsProvider);

    // Calculate stats
    final totalCvs = userCvs.length;
    final pendingCvs = userCvs.where((c) => c.status == 'PENDING').length;
    final inProgressCvs = userCvs.where((c) => c.status == 'IN_PROGRESS' || c.status == 'ASSIGNED' || c.status == 'UNDER_REVIEW').length;
    final approvedCvs = userCvs.where((c) => c.status == 'APPROVED').length;
    final completedCvs = userCvs.where((c) => c.status == 'COMPLETED' || c.status == 'APPROVED').length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.contentPadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back, ${user?.displayName ?? 'Candidate'}! 👋',
                          style: AppTextStyles.heading2.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Track your handcrafted CVs, manage your live portfolio, or submit a new position request.',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.sidebarText),
                        ),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => context.go('/dashboard/create-cv'),
                              icon: const Icon(Icons.add_circle_outline, size: 18),
                              label: const Text('Create New CV Request'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accent,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => context.go('/dashboard/search'),
                              icon: const Icon(Icons.search, size: 18, color: Colors.white),
                              label: const Text('Explore Job Positions', style: TextStyle(color: Colors.white)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.white30),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Metrics Grid
            Text('Overview Metrics', style: AppTextStyles.heading3),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = Responsive.dashboardCrossAxisCount(context);
                return GridView.count(
                  crossAxisCount: crossAxisCount > 2 ? 5 : (crossAxisCount == 2 ? 2 : 1),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.5,
                  children: [
                    StatCard(
                      title: 'Total CVs',
                      value: '$totalCvs',
                      icon: Icons.description_outlined,
                      iconColor: AppColors.accent,
                      onTap: () => context.go('/dashboard/my-cvs'),
                    ),
                    StatCard(
                      title: 'Pending Review',
                      value: '$pendingCvs',
                      icon: Icons.hourglass_top_outlined,
                      iconColor: AppColors.warning,
                      onTap: () => context.go('/dashboard/my-cvs'),
                    ),
                    StatCard(
                      title: 'Under Processing',
                      value: '$inProgressCvs',
                      icon: Icons.engineering_outlined,
                      iconColor: AppColors.secondary,
                      onTap: () => context.go('/dashboard/my-cvs'),
                    ),
                    StatCard(
                      title: 'Approved CVs',
                      value: '$approvedCvs',
                      icon: Icons.check_circle_outline,
                      iconColor: AppColors.success,
                      subtitle: 'Ready to download',
                      onTap: () => context.go('/dashboard/my-cvs'),
                    ),
                    StatCard(
                      title: 'Completed',
                      value: '$completedCvs',
                      icon: Icons.done_all_outlined,
                      iconColor: AppColors.accentDark,
                      onTap: () => context.go('/dashboard/my-cvs'),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),

            // Recent CVs List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent CV Requests', style: AppTextStyles.heading3),
                TextButton.icon(
                  onPressed: () => context.go('/dashboard/my-cvs'),
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: const Text('View All CVs'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (userCvs.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.post_add, size: 48, color: AppColors.textTertiary),
                        const SizedBox(height: 12),
                        Text('No CV requests yet', style: AppTextStyles.heading4),
                        const SizedBox(height: 8),
                        Text(
                          'Submit your work history and skills to have an expert craft your CV.',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => context.go('/dashboard/create-cv'),
                          child: const Text('Create First CV'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: userCvs.take(4).length,
                separatorBuilder: (context, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final cv = userCvs[index];
                  final isApproved = cv.status == 'APPROVED';

                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.description_outlined, color: AppColors.accent, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(cv.title, style: AppTextStyles.heading4),
                                    const SizedBox(width: 12),
                                    StatusBadge(status: cv.status),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Target Position: ${cv.position} • Submitted: ${cv.createdAt.day}/${cv.createdAt.month}/${cv.createdAt.year}',
                                  style: AppTextStyles.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Wrap(
                            spacing: 8,
                            children: [
                              OutlinedButton(
                                onPressed: () => context.go('/dashboard/cv/${cv.id}'),
                                child: const Text('View Details'),
                              ),
                              if (isApproved)
                                ElevatedButton.icon(
                                  onPressed: () => context.go('/dashboard/cv/${cv.id}'),
                                  icon: const Icon(Icons.download, size: 16),
                                  label: const Text('Download Original'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.success,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

