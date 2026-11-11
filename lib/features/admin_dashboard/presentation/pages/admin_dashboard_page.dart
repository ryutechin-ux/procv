import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/theme/responsive.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../services/mock_data_service.dart';

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allUsers = ref.watch(allUsersProvider);
    final allCvs = ref.watch(allCvRequestsProvider);
    final allAssignments = ref.watch(allWorkAssignmentsProvider);
    final submissions = ref.watch(cvSubmissionsProvider);

    // Compute metrics
    final totalUsers = allUsers.length;
    final totalCvRequests = allCvs.length;
    final pendingRequests = allCvs.where((c) => c.status == 'PENDING').length;
    final assignedWorks = allAssignments.where((a) => a.status == 'ASSIGNED').length;
    final inProgress = allCvs.where((c) => c.status == 'IN_PROGRESS').length;
    final submittedForReview = allCvs.where((c) => c.status == 'SUBMITTED_FOR_REVIEW').length;
    final approvedCvs = allCvs.where((c) => c.status == 'APPROVED').length;
    final rejectedCvs = allCvs.where((c) => c.status == 'REJECTED').length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.contentPadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Admin Banner
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
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
                        Text('Operations & HR Control Center', style: AppTextStyles.heading2.copyWith(color: Colors.white)),
                        const SizedBox(height: 8),
                        Text(
                          'Oversee user requests, allocate tasks to CV developers, approve submissions, and maintain quality assurance.',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.sidebarText),
                        ),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => context.go('/admin/assign-work'),
                              icon: const Icon(Icons.person_add_alt_1, size: 18),
                              label: const Text('Assign Developer to CV'),
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: Colors.white),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => context.go('/admin/review'),
                              icon: const Icon(Icons.rate_review, size: 18),
                              label: Text('Review Submissions ($submittedForReview)'),
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary, foregroundColor: Colors.white),
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

            // Statistics Grid (8 Metrics required by specification)
            Text('Platform Operations Statistics', style: AppTextStyles.heading3),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = Responsive.dashboardCrossAxisCount(context);
                return GridView.count(
                  crossAxisCount: crossAxisCount > 2 ? 4 : (crossAxisCount == 2 ? 2 : 1),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.5,
                  children: [
                    StatCard(
                      title: 'Total Users',
                      value: '$totalUsers',
                      icon: Icons.people_outline,
                      iconColor: AppColors.accent,
                      onTap: () => context.go('/admin/users'),
                    ),
                    StatCard(
                      title: 'Total CV Requests',
                      value: '$totalCvRequests',
                      icon: Icons.description_outlined,
                      iconColor: AppColors.secondary,
                      onTap: () => context.go('/admin/cv-requests'),
                    ),
                    StatCard(
                      title: 'Pending Requests',
                      value: '$pendingRequests',
                      icon: Icons.hourglass_empty,
                      iconColor: AppColors.warning,
                      subtitle: 'Needs assignment',
                      onTap: () => context.go('/admin/assign-work'),
                    ),
                    StatCard(
                      title: 'Assigned Works',
                      value: '$assignedWorks',
                      icon: Icons.assignment_ind_outlined,
                      iconColor: AppColors.accentLight,
                      onTap: () => context.go('/admin/assign-work'),
                    ),
                    StatCard(
                      title: 'In Progress',
                      value: '$inProgress',
                      icon: Icons.engineering_outlined,
                      iconColor: AppColors.info,
                      onTap: () => context.go('/admin/cv-requests'),
                    ),
                    StatCard(
                      title: 'Submitted for Review',
                      value: '$submittedForReview',
                      icon: Icons.rate_review_outlined,
                      iconColor: AppColors.accentDark,
                      subtitle: 'Awaiting HR action',
                      onTap: () => context.go('/admin/review'),
                    ),
                    StatCard(
                      title: 'Approved CVs',
                      value: '$approvedCvs',
                      icon: Icons.check_circle_outline,
                      iconColor: AppColors.success,
                      onTap: () => context.go('/admin/cv-requests'),
                    ),
                    StatCard(
                      title: 'Rejected / Revision',
                      value: '$rejectedCvs',
                      icon: Icons.cancel_outlined,
                      iconColor: AppColors.error,
                      onTap: () => context.go('/admin/cv-requests'),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),

            // Pending Submissions Requiring Immediate Review
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Submissions Awaiting Admin Decision', style: AppTextStyles.heading3),
                TextButton(
                  onPressed: () => context.go('/admin/review'),
                  child: const Text('View All Submissions'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (submissions.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.done_all, size: 48, color: AppColors.success),
                        const SizedBox(height: 12),
                        Text('No pending reviews', style: AppTextStyles.heading4),
                        const SizedBox(height: 6),
                        Text('All developer submissions have been processed.', style: AppTextStyles.bodyMedium),
                      ],
                    ),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: submissions.take(3).length,
                separatorBuilder: (context, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final sub = submissions[index];
                  final cv = allCvs.firstWhere((c) => c.id == sub.cvRequestId, orElse: () => allCvs.first);

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.rate_review_outlined, color: AppColors.accent, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(cv.title, style: AppTextStyles.labelLarge),
                                    const SizedBox(width: 8),
                                    StatusBadge(status: sub.status),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Candidate: ${cv.personalInfo?.fullName ?? "Candidate"} • Position: ${cv.position}',
                                  style: AppTextStyles.bodySmall,
                                ),
                                if (sub.notes != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text('Dev Note: "${sub.notes}"', style: AppTextStyles.caption),
                                  ),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => context.go('/admin/review'),
                            icon: const Icon(Icons.rule, size: 16),
                            label: const Text('Review & Decide'),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
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

