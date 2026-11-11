import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/theme/responsive.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../services/mock_data_service.dart';

class DeveloperDashboardPage extends ConsumerWidget {
  const DeveloperDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final myAssignments = ref.watch(developerAssignmentsProvider);

    // Calculate Developer Statistics
    final assignedCount = myAssignments.length;
    final pendingCount = myAssignments.where((w) => w.status == 'ASSIGNED').length;
    final inProgressCount = myAssignments.where((w) => w.status == 'IN_PROGRESS').length;
    final submittedCount = myAssignments.where((w) => w.status == 'SUBMITTED_FOR_REVIEW').length;
    final revisionCount = myAssignments.where((w) => w.status == 'REVISION_REQUIRED').length;
    final completedCount = myAssignments.where((w) => w.status == 'COMPLETED' || w.status == 'APPROVED').length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.contentPadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Developer Header Banner
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.accentDark, AppColors.primaryLight],
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
                          'Developer Workspace • ${user?.displayName ?? 'Developer'}',
                          style: AppTextStyles.heading2.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Review assigned candidate requests, craft professional CVs, and upload watermarked & original PDFs for HR review.',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.sidebarText),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => context.go('/developer/assigned-works'),
                          icon: const Icon(Icons.assignment, size: 18),
                          label: const Text('View Assigned Works'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Statistics Grid (Assigned Works, Pending Works, In Progress, Submitted for Review, Revision Required, Completed Works)
            Text('Development Workload Metrics', style: AppTextStyles.heading3),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = Responsive.dashboardCrossAxisCount(context);
                return GridView.count(
                  crossAxisCount: crossAxisCount > 2 ? 6 : (crossAxisCount == 2 ? 3 : 2),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.4,
                  children: [
                    StatCard(
                      title: 'Assigned',
                      value: '$assignedCount',
                      icon: Icons.assignment_outlined,
                      iconColor: AppColors.secondary,
                      onTap: () => context.go('/developer/assigned-works'),
                    ),
                    StatCard(
                      title: 'Pending Start',
                      value: '$pendingCount',
                      icon: Icons.pending_actions_outlined,
                      iconColor: AppColors.warning,
                      onTap: () => context.go('/developer/assigned-works'),
                    ),
                    StatCard(
                      title: 'In Progress',
                      value: '$inProgressCount',
                      icon: Icons.engineering_outlined,
                      iconColor: AppColors.accentLight,
                      onTap: () => context.go('/developer/assigned-works'),
                    ),
                    StatCard(
                      title: 'Submitted',
                      value: '$submittedCount',
                      icon: Icons.rate_review_outlined,
                      iconColor: AppColors.accent,
                      onTap: () => context.go('/developer/assigned-works'),
                    ),
                    StatCard(
                      title: 'Revision Needed',
                      value: '$revisionCount',
                      icon: Icons.error_outline,
                      iconColor: AppColors.error,
                      subtitle: 'Needs attention',
                      onTap: () => context.go('/developer/assigned-works'),
                    ),
                    StatCard(
                      title: 'Completed',
                      value: '$completedCount',
                      icon: Icons.task_alt_outlined,
                      iconColor: AppColors.success,
                      onTap: () => context.go('/developer/assigned-works'),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),

            // Active Queue Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Active Task Queue', style: AppTextStyles.heading3),
                TextButton(
                  onPressed: () => context.go('/developer/assigned-works'),
                  child: const Text('View All Works'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (myAssignments.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.check_circle_outline, size: 48, color: AppColors.success),
                        const SizedBox(height: 12),
                        Text('All caught up!', style: AppTextStyles.heading4),
                        const SizedBox(height: 6),
                        Text('No active CV requests currently assigned to you.', style: AppTextStyles.bodyMedium),
                      ],
                    ),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: myAssignments.length,
                separatorBuilder: (context, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final wa = myAssignments[index];
                  final isRevision = wa.status == 'REVISION_REQUIRED';

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isRevision ? AppColors.error.withValues(alpha: 0.5) : AppColors.border,
                        width: isRevision ? 1.5 : 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isRevision
                                  ? AppColors.errorLight
                                  : AppColors.accent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isRevision ? Icons.warning_amber_rounded : Icons.person_pin_outlined,
                              color: isRevision ? AppColors.error : AppColors.accent,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text('Candidate: ${wa.userName}', style: AppTextStyles.labelLarge),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: _priorityColor(wa.priority).withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '${wa.priority} PRIORITY',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: _priorityColor(wa.priority),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    StatusBadge(status: wa.status),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Position: ${wa.cvPosition} • Assigned: ${wa.assignedAt.day}/${wa.assignedAt.month}/${wa.assignedAt.year}',
                                  style: AppTextStyles.bodySmall,
                                ),
                                if (wa.instructions != null) ...[
                                  const SizedBox(height: 4),
                                  Text('Admin Note: "${wa.instructions}"',
                                      style: AppTextStyles.caption.copyWith(fontStyle: FontStyle.italic)),
                                ],
                              ],
                            ),
                          ),
                          Wrap(
                            spacing: 8,
                            children: [
                              OutlinedButton(
                                onPressed: () => context.go('/developer/work/${wa.id}'),
                                child: const Text('View User Details'),
                              ),
                              ElevatedButton.icon(
                                onPressed: () => context.go('/developer/submit/${wa.id}'),
                                icon: const Icon(Icons.upload_file, size: 16),
                                label: const Text('Submit CV Draft'),
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

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'URGENT':
        return AppColors.error;
      case 'HIGH':
        return AppColors.warning;
      case 'MEDIUM':
        return AppColors.secondary;
      default:
        return AppColors.textTertiary;
    }
  }
}

