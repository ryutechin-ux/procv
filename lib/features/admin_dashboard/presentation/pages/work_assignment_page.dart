import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/theme/responsive.dart';
import '../../../../features/developer_dashboard/data/models/work_assignment_model.dart';
import '../../../../features/notifications/data/models/notification_model.dart';
import '../../../../firebase_bootstrap.dart';
import '../../../../services/mock_data_service.dart';

class WorkAssignmentPage extends ConsumerStatefulWidget {
  const WorkAssignmentPage({super.key});

  @override
  ConsumerState<WorkAssignmentPage> createState() => _WorkAssignmentPageState();
}

class _WorkAssignmentPageState extends ConsumerState<WorkAssignmentPage> {
  String? _selectedCvRequestId;
  String? _selectedDeveloperId;
  String _selectedPriority = 'HIGH';
  final _instructionsController = TextEditingController(
    text: 'Create modern ATS-compliant resume. Prioritize cross-platform technical achievements and clean layout.',
  );
  bool _isAssigning = false;

  @override
  void dispose() {
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _handleAssign() async {
    if (_selectedCvRequestId == null || _selectedDeveloperId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.error,
          content: Text(
            'Please select both a CV Request and an available Developer.',
          ),
        ),
      );
      return;
    }

    setState(() => _isAssigning = true);

    final cvList = ref.read(allCvRequestsProvider);
    final devList = ref.read(developersProvider);

    final selectedCv = cvList.firstWhere((c) => c.id == _selectedCvRequestId);
    final selectedDev = devList.firstWhere(
      (d) => d.id == _selectedDeveloperId,
    );

    try {
      if (firebaseConfigured) {
        final currentAdmin = ref.read(currentUserProvider);
        await ref.read(firebaseRepositoryProvider).assignWork(
          cv: selectedCv,
          developer: selectedDev,
          adminId: currentAdmin?.uid ?? 'admin_001',
          priority: _selectedPriority,
          instructions: _instructionsController.text.trim(),
        );
      } else {
        // 1. Create Work Assignment Record
        final newAssignment = WorkAssignmentModel(
          id: 'wa_${DateTime.now().millisecondsSinceEpoch}',
          cvRequestId: selectedCv.id,
          developerId: selectedDev.userId,
          developerName: selectedDev.name,
          adminId: 'admin_001',
          priority: _selectedPriority,
          instructions: _instructionsController.text.trim(),
          status: 'ASSIGNED',
          userName: selectedCv.personalInfo?.fullName ?? 'Candidate',
          cvPosition: selectedCv.position,
          assignedAt: DateTime.now(),
        );
        MockDataService.workAssignments.insert(0, newAssignment);

        // 2. Update Request Status to ASSIGNED
        final cvIdx = MockDataService.cvRequests.indexWhere(
          (c) => c.id == selectedCv.id,
        );
        if (cvIdx != -1) {
          MockDataService.cvRequests[cvIdx] = selectedCv.copyWith(
            status: 'ASSIGNED',
          );
        }

        // 3. Notify the Developer
        MockDataService.notifications.insert(
          0,
          NotificationModel(
            id: 'notif_${DateTime.now().millisecondsSinceEpoch}_dev',
            userId: selectedDev.userId,
            title: 'New Work Assigned ($_selectedPriority Priority)',
            message:
                'You have been assigned to prepare the CV for "${selectedCv.position}".',
            type: 'NEW_WORK_ASSIGNED',
            relatedRequestId: selectedCv.id,
            createdAt: DateTime.now(),
          ),
        );

        // 4. Notify the User
        MockDataService.notifications.insert(
          0,
          NotificationModel(
            id: 'notif_${DateTime.now().millisecondsSinceEpoch}_user',
            userId: selectedCv.userId,
            title: 'CV Work Assigned',
            message:
                'Great news! Your CV request for "${selectedCv.position}" has been assigned to expert developer ${selectedDev.name}.',
            type: 'CV_ASSIGNED',
            relatedRequestId: selectedCv.id,
            createdAt: DateTime.now(),
          ),
        );
      }

      if (!mounted) return;
      setState(() => _isAssigning = false);

      // Show confirmation dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  size: 54,
                  color: AppColors.success,
                ),
                const SizedBox(height: 16),
                Text(
                  'Work Assigned Successfully!',
                  style: AppTextStyles.heading3,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Task assigned to ${selectedDev.name}.\nBoth the developer and candidate have been notified.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.go('/admin/cv-requests');
                  },
                  child: const Text('Go to CV Requests'),
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
      if (mounted) setState(() => _isAssigning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final allCvs = ref.watch(allCvRequestsProvider);
    final developers = ref
        .watch(developersProvider)
        .where((d) => d.isActive)
        .toList();

    // Requests that need assignment
    final assignableCvs = allCvs
        .where(
          (c) =>
              c.status == 'PENDING' ||
              c.status == 'REVISION_REQUIRED' ||
              c.status == 'DRAFT',
        )
        .toList();

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
                    Text(
                      'CV Work Assignment Console',
                      style: AppTextStyles.heading2,
                    ),
                    Text(
                      'Pair candidate submissions with specialized CV developers.',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Step 1: Select Request
                      Text(
                        '1. Select Pending CV Request',
                        style: AppTextStyles.heading4,
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCvRequestId,
                        hint: const Text('Choose a candidate CV request...'),
                        isExpanded: true,
                        items: assignableCvs.map((cv) {
                          return DropdownMenuItem(
                            value: cv.id,
                            child: Text(
                              '${cv.title} (${cv.position}) — ${cv.status}',
                            ),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setState(() => _selectedCvRequestId = val),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.description_outlined),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Step 2: Select Developer
                      Text(
                        '2. Select Developer',
                        style: AppTextStyles.heading4,
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedDeveloperId,
                        hint: const Text('Select an active developer...'),
                        isExpanded: true,
                        items: developers.map((dev) {
                          return DropdownMenuItem(
                            value: dev.id,
                            child: Text(
                              '${dev.name} (${dev.email}) — ${dev.assignedCount} Active Tasks',
                            ),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setState(() => _selectedDeveloperId = val),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.engineering_outlined),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Step 3: Priority
                      Text(
                        '3. Set Priority Level',
                        style: AppTextStyles.heading4,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        children: ['LOW', 'MEDIUM', 'HIGH', 'URGENT'].map((p) {
                          final isSelected = _selectedPriority == p;
                          Color color = AppColors.secondary;
                          if (p == 'URGENT') color = AppColors.error;
                          if (p == 'HIGH') color = AppColors.warning;

                          return ChoiceChip(
                            label: Text(p),
                            selected: isSelected,
                            onSelected: (val) {
                              if (val) setState(() => _selectedPriority = p);
                            },
                            selectedColor: color,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // Step 4: Instructions
                      Text(
                        '4. Developer Instructions & Special Directives',
                        style: AppTextStyles.heading4,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _instructionsController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'Enter specific guidance regarding candidate preferences, formatting, or target industry standard...',
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Submit Assignment Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isAssigning ? null : _handleAssign,
                          icon: const Icon(Icons.assignment_turned_in_outlined),
                          label: _isAssigning
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Assign Work & Notify Team',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            backgroundColor: AppColors.accent,
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
      ),
    );
  }
}
