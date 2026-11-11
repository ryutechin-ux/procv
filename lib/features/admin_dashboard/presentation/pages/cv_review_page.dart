import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/theme/responsive.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../features/developer_dashboard/data/models/work_assignment_model.dart';
import '../../../../features/notifications/data/models/notification_model.dart';
import '../../../../firebase_bootstrap.dart';
import '../../../../services/mock_data_service.dart';

class CvReviewPage extends ConsumerStatefulWidget {
  const CvReviewPage({super.key});

  @override
  ConsumerState<CvReviewPage> createState() => _CvReviewPageState();
}

class _CvReviewPageState extends ConsumerState<CvReviewPage> {
  final _revisionReasonCtrl = TextEditingController();

  @override
  void dispose() {
    _revisionReasonCtrl.dispose();
    super.dispose();
  }

  void _handleApprove(CvSubmissionModel sub) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm CV Approval'),
        content: const Text(
          'Approving this CV will:\n\n'
          '• Update the request status to APPROVED\n'
          '• Record your Admin ID and timestamp\n'
          '• Enable the clean original PDF download for the candidate\n'
          '• Send an instant push and in-app notification to the candidate',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _executeApproval(sub);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('Approve & Release'),
          ),
        ],
      ),
    );
  }

  Future<void> _executeApproval(CvSubmissionModel sub) async {
    try {
      if (firebaseConfigured) {
        final admin = ref.read(currentUserProvider);
        await ref.read(firebaseRepositoryProvider).approveSubmission(
          sub,
          adminId: admin?.uid ?? 'admin_001',
        );
      } else {
        setState(() {
          // 1. Update CV Request status to APPROVED
          final cvIdx = MockDataService.cvRequests.indexWhere((c) => c.id == sub.cvRequestId);
          if (cvIdx != -1) {
            final oldCv = MockDataService.cvRequests[cvIdx];
            MockDataService.cvRequests[cvIdx] = oldCv.copyWith(status: 'APPROVED', updatedAt: DateTime.now());

            // 2. Notify candidate
            MockDataService.notifications.insert(
              0,
              NotificationModel(
                id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
                userId: oldCv.userId,
                title: 'Your Professional CV is Approved! 🎉',
                message: 'Your CV for "${oldCv.position}" has passed our quality check. The final watermark-free PDF is now unlocked for download.',
                type: 'CV_APPROVED',
                relatedRequestId: oldCv.id,
                createdAt: DateTime.now(),
              ),
            );
          }

          // 3. Update Submission status
          final subIdx = MockDataService.cvSubmissions.indexWhere((s) => s.id == sub.id);
          if (subIdx != -1) {
            MockDataService.cvSubmissions[subIdx] = CvSubmissionModel(
              id: sub.id,
              cvRequestId: sub.cvRequestId,
              developerId: sub.developerId,
              watermarkedPdfUrl: sub.watermarkedPdfUrl,
              originalPdfUrl: sub.originalPdfUrl,
              notes: sub.notes,
              status: 'APPROVED',
              submittedAt: sub.submittedAt,
              reviewedBy: 'admin_001',
              reviewedAt: DateTime.now(),
            );
          }

          // 4. Update Developer work assignment
          final waIdx = MockDataService.workAssignments.indexWhere((w) => w.cvRequestId == sub.cvRequestId);
          if (waIdx != -1) {
            final oldWa = MockDataService.workAssignments[waIdx];
            MockDataService.workAssignments[waIdx] = WorkAssignmentModel(
              id: oldWa.id,
              cvRequestId: oldWa.cvRequestId,
              developerId: oldWa.developerId,
              developerName: oldWa.developerName,
              adminId: oldWa.adminId,
              priority: oldWa.priority,
              instructions: oldWa.instructions,
              status: 'COMPLETED',
              userName: oldWa.userName,
              cvPosition: oldWa.cvPosition,
              assignedAt: oldWa.assignedAt,
              updatedAt: DateTime.now(),
            );
          }
        });
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.success,
          content: Text('CV successfully approved! Original PDF unlocked for candidate.'),
        ),
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

  void _handleRequestRevision(CvSubmissionModel sub) {
    _revisionReasonCtrl.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Request CV Revision'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'A detailed revision reason is mandatory. The assigned developer will be notified and tasked with revisions.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _revisionReasonCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Revision Feedback *',
                hintText: 'e.g. Please expand the professional summary and align technical keywords with enterprise ATS requirements...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (_revisionReasonCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter revision feedback')),
                );
                return;
              }
              Navigator.pop(context);
              _executeRevision(sub, _revisionReasonCtrl.text.trim());
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Send Revision Request'),
          ),
        ],
      ),
    );
  }

  Future<void> _executeRevision(CvSubmissionModel sub, String reason) async {
    try {
      if (firebaseConfigured) {
        await ref.read(firebaseRepositoryProvider).requestRevision(sub, reason: reason);
      } else {
        setState(() {
          // 1. Update CV Request status
          final cvIdx = MockDataService.cvRequests.indexWhere((c) => c.id == sub.cvRequestId);
          if (cvIdx != -1) {
            final oldCv = MockDataService.cvRequests[cvIdx];
            MockDataService.cvRequests[cvIdx] = oldCv.copyWith(status: 'REVISION_REQUIRED', updatedAt: DateTime.now());
          }

          // 2. Update Work Assignment status
          final waIdx = MockDataService.workAssignments.indexWhere((w) => w.cvRequestId == sub.cvRequestId);
          if (waIdx != -1) {
            final oldWa = MockDataService.workAssignments[waIdx];
            MockDataService.workAssignments[waIdx] = WorkAssignmentModel(
              id: oldWa.id,
              cvRequestId: oldWa.cvRequestId,
              developerId: oldWa.developerId,
              developerName: oldWa.developerName,
              adminId: oldWa.adminId,
              priority: 'URGENT',
              instructions: 'REVISION: $reason',
              status: 'REVISION_REQUIRED',
              userName: oldWa.userName,
              cvPosition: oldWa.cvPosition,
              assignedAt: oldWa.assignedAt,
              updatedAt: DateTime.now(),
            );

            // 3. Notify the assigned developer
            MockDataService.notifications.insert(
              0,
              NotificationModel(
                id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
                userId: oldWa.developerId,
                title: 'Revision Requested for ${oldWa.userName}',
                message: 'Admin has requested revisions: "$reason"',
                type: 'REVISION_REQUESTED',
                relatedRequestId: oldWa.cvRequestId,
                createdAt: DateTime.now(),
              ),
            );
          }
        });
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.error,
          content: Text('Revision request sent to developer with urgent priority.'),
        ),
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

  @override
  Widget build(BuildContext context) {
    final submissions = ref.watch(cvSubmissionsProvider);
    final allCvs = ref.watch(allCvRequestsProvider);
    final developers = ref.watch(developersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.contentPadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CV Review & Approval Center', style: AppTextStyles.heading2),
                    Text('Inspect developer creations, compare drafts, and approve or request revision.', style: AppTextStyles.bodySmall),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            if (submissions.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(48),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.rate_review_outlined, size: 48, color: AppColors.textTertiary),
                        const SizedBox(height: 16),
                        Text('No Submissions Awaiting Review', style: AppTextStyles.heading4),
                      ],
                    ),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: submissions.length,
                separatorBuilder: (context, _) => const SizedBox(height: 20),
                itemBuilder: (context, index) {
                  final sub = submissions[index];
                  final cv = allCvs.firstWhere((c) => c.id == sub.cvRequestId, orElse: () => allCvs.first);
                  final dev = developers.firstWhere((d) => d.userId == sub.developerId, orElse: () => developers.first);
                  final isPendingReview = sub.status == 'SUBMITTED_FOR_REVIEW';

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.rate_review, color: AppColors.accent, size: 28),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text('CV: ${cv.title}', style: AppTextStyles.heading3),
                                        const SizedBox(width: 12),
                                        StatusBadge(status: sub.status),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text('Target Position: ${cv.position}', style: AppTextStyles.bodyMedium),
                                    Text(
                                      'Submitted on: ${sub.submittedAt.day}/${sub.submittedAt.month}/${sub.submittedAt.year}',
                                      style: AppTextStyles.caption,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Divider(),
                          const SizedBox(height: 16),

                          // Two Column Overview: User info vs Developer info
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceVariant,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Candidate Details', style: AppTextStyles.labelLarge),
                                      const SizedBox(height: 8),
                                      Text('Name: ${cv.personalInfo?.fullName ?? "Candidate"}'),
                                      Text('Email: ${cv.personalInfo?.email ?? "N/A"}'),
                                      Text('Phone: ${cv.personalInfo?.phone ?? "N/A"}'),
                                      Text('Experience: ${cv.professionalInfo?.totalExperience ?? "N/A"}'),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceVariant,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Developer Details', style: AppTextStyles.labelLarge),
                                      const SizedBox(height: 8),
                                      Text('Name: ${dev.name}'),
                                      Text('Email: ${dev.email}'),
                                      if (sub.notes != null) ...[
                                        const SizedBox(height: 6),
                                        Text('Developer Notes: "${sub.notes}"', style: AppTextStyles.caption),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // PDF Access Badges
                          Row(
                            children: [
                              Chip(
                                avatar: const Icon(Icons.picture_as_pdf, color: AppColors.secondary, size: 16),
                                label: const Text('Watermarked PDF (Preview Enabled)'),
                              ),
                              const SizedBox(width: 12),
                              Chip(
                                avatar: const Icon(Icons.verified, color: AppColors.success, size: 16),
                                label: const Text('Original PDF (Production Ready)'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Divider(),
                          const SizedBox(height: 16),

                          // Admin Actions: APPROVE or REQUEST REVISION
                          if (isPendingReview)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () => _handleRequestRevision(sub),
                                  icon: const Icon(Icons.replay, color: AppColors.error, size: 16),
                                  label: const Text('Request Revision', style: TextStyle(color: AppColors.error)),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: AppColors.error),
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton.icon(
                                  onPressed: () => _handleApprove(sub),
                                  icon: const Icon(Icons.check_circle_outline, size: 18),
                                  label: const Text('Approve & Release to Candidate'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.success,
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                  ),
                                ),
                              ],
                            )
                          else
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                sub.status == 'APPROVED' ? '✅ This submission was Approved by Admin' : '⚠️ Revision was requested for this work',
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: sub.status == 'APPROVED' ? AppColors.success : AppColors.error,
                                ),
                              ),
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

