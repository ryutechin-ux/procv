import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/theme/responsive.dart';
import '../../../../features/developer_dashboard/data/models/work_assignment_model.dart';
import '../../../../firebase_bootstrap.dart';
import '../../../../services/mock_data_service.dart';

class CvSubmissionPage extends ConsumerStatefulWidget {
  final String assignmentId;

  const CvSubmissionPage({super.key, required this.assignmentId});

  @override
  ConsumerState<CvSubmissionPage> createState() => _CvSubmissionPageState();
}

class _CvSubmissionPageState extends ConsumerState<CvSubmissionPage> {
  final _notesController = TextEditingController();
  String? _watermarkedFileName;
  String? _originalFileName;
  bool _isUploading = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _simulatePickWatermarkedFile() {
    setState(() {
      _watermarkedFileName = 'watermarked_${DateTime.now().millisecondsSinceEpoch}.pdf (2.4 MB)';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Watermarked PDF selected successfully')),
    );
  }

  void _simulatePickOriginalFile() {
    setState(() {
      _originalFileName = 'original_production_${DateTime.now().millisecondsSinceEpoch}.pdf (2.1 MB)';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Original watermark-free PDF selected successfully')),
    );
  }

  Future<void> _handleSubmit() async {
    if (_watermarkedFileName == null || _originalFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.error,
          content: Text('Please upload both the watermarked PDF and the original PDF.'),
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    final assignments = ref.read(allWorkAssignmentsProvider);
    final waIndex = assignments.indexWhere((a) => a.id == widget.assignmentId);

    if (waIndex == -1) {
      setState(() => _isUploading = false);
      return;
    }

    final current = assignments[waIndex];

    try {
      if (firebaseConfigured) {
        await ref.read(firebaseRepositoryProvider).submitWork(
          assignment: current,
          notes: _notesController.text.trim(),
          watermarkedPdfUrl: 'https://procv.storage/watermarked.pdf',
          originalPdfUrl: 'https://procv.storage/original.pdf',
        );
      } else {
        // Create work assignment update
        MockDataService.workAssignments[waIndex] = WorkAssignmentModel(
          id: current.id,
          cvRequestId: current.cvRequestId,
          developerId: current.developerId,
          developerName: current.developerName,
          adminId: current.adminId,
          priority: current.priority,
          instructions: current.instructions,
          status: 'SUBMITTED_FOR_REVIEW',
          userName: current.userName,
          cvPosition: current.cvPosition,
          assignedAt: current.assignedAt,
          updatedAt: DateTime.now(),
        );

        // Update CV Request status
        final cvIndex = MockDataService.cvRequests.indexWhere((c) => c.id == current.cvRequestId);
        if (cvIndex != -1) {
          final oldCv = MockDataService.cvRequests[cvIndex];
          MockDataService.cvRequests[cvIndex] = oldCv.copyWith(status: 'SUBMITTED_FOR_REVIEW');
        }

        // Add Submission record
        MockDataService.cvSubmissions.insert(
          0,
          CvSubmissionModel(
            id: 'sub_${DateTime.now().millisecondsSinceEpoch}',
            cvRequestId: current.cvRequestId,
            developerId: current.developerId,
            watermarkedPdfUrl: 'https://procv.storage/watermarked.pdf',
            originalPdfUrl: 'https://procv.storage/original.pdf',
            notes: _notesController.text.trim(),
            status: 'SUBMITTED_FOR_REVIEW',
            submittedAt: DateTime.now(),
          ),
        );
      }

      if (!mounted) return;
      setState(() => _isUploading = false);

      // Dialog confirmation explaining that developers cannot approve their own submissions
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.send_rounded, size: 54, color: AppColors.accent),
                const SizedBox(height: 20),
                Text('Submitted for Admin Approval', style: AppTextStyles.heading3, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                Text(
                  'Your crafted CV has been sent to HR / Admin for review.\n\nNote: Developer self-approval is restricted. The candidate will be notified and original PDF unlocked once an Admin completes the formal approval.',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.go('/developer/assigned-works');
                  },
                  child: const Text('Back to Assigned Works'),
                ),
              ],
            ),
          ),
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
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final assignments = ref.watch(allWorkAssignmentsProvider);
    final wa = assignments.firstWhere(
      (a) => a.id == widget.assignmentId,
      orElse: () => assignments.first,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.contentPadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Submit Handcrafted CV', style: AppTextStyles.heading2),
                    Text('For: ${wa.userName} (${wa.cvPosition})', style: AppTextStyles.bodySmall),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Submission Guidelines Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.rule_folder_outlined, color: AppColors.accent, size: 28),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Submission Protocol: Upload both (1) Watermarked PDF (visible to user immediately) and (2) Original Clean PDF (securely vaulted, unlocked strictly upon Admin approval).',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Two upload sections
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Watermarked PDF Box
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.branding_watermark_outlined, color: AppColors.secondary),
                              const SizedBox(width: 10),
                              Text('1. Watermarked PDF', style: AppTextStyles.heading4),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Must have "PROCV PREVIEW" diagonal watermark. Candidate can preview this version.',
                            style: AppTextStyles.bodySmall,
                          ),
                          const SizedBox(height: 20),
                          InkWell(
                            onTap: _simulatePickWatermarkedFile,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              height: 140,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.secondary, style: BorderStyle.solid),
                                borderRadius: BorderRadius.circular(12),
                                color: AppColors.surfaceVariant,
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.cloud_upload_outlined, size: 36, color: AppColors.secondary),
                                    const SizedBox(height: 8),
                                    Text(
                                      _watermarkedFileName ?? 'Click to Browse & Upload Watermarked PDF',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: _watermarkedFileName != null ? FontWeight.bold : FontWeight.normal,
                                        color: _watermarkedFileName != null ? AppColors.success : AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),

                // Original PDF Box
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.verified_outlined, color: AppColors.success),
                              const SizedBox(width: 10),
                              Text('2. Original PDF (Unwatermarked)', style: AppTextStyles.heading4),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Final production quality resume. Kept private until Admin approval.',
                            style: AppTextStyles.bodySmall,
                          ),
                          const SizedBox(height: 20),
                          InkWell(
                            onTap: _simulatePickOriginalFile,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              height: 140,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.success, style: BorderStyle.solid),
                                borderRadius: BorderRadius.circular(12),
                                color: AppColors.surfaceVariant,
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.cloud_upload_outlined, size: 36, color: AppColors.success),
                                    const SizedBox(height: 8),
                                    Text(
                                      _originalFileName ?? 'Click to Browse & Upload Original PDF',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: _originalFileName != null ? FontWeight.bold : FontWeight.normal,
                                        color: _originalFileName != null ? AppColors.success : AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Developer Submission Notes
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('3. Developer Commentary & Notes for Admin', style: AppTextStyles.heading4),
                    const SizedBox(height: 8),
                    Text(
                      'Explain design choices, layout template used, ATS keywords addressed, and recommendations.',
                      style: AppTextStyles.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _notesController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Crafted modern two-column layout focusing on technical leadership in Flutter. Optimized headline for senior ATS filters...',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => context.pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _isUploading ? null : _handleSubmit,
                  icon: const Icon(Icons.send_outlined),
                  label: _isUploading
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Submit for Admin Approval'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                    backgroundColor: AppColors.accent,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

