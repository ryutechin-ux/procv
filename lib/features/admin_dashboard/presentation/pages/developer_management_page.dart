import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/theme/responsive.dart';
import '../../../../features/developer_dashboard/data/models/work_assignment_model.dart';
import '../../../../firebase_bootstrap.dart';
import '../../../../services/mock_data_service.dart';

class DeveloperManagementPage extends ConsumerStatefulWidget {
  const DeveloperManagementPage({super.key});

  @override
  ConsumerState<DeveloperManagementPage> createState() =>
      _DeveloperManagementPageState();
}

class _DeveloperManagementPageState
    extends ConsumerState<DeveloperManagementPage> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _showAddDeveloperDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add CV Developer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Developer Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailCtrl,
              decoration: const InputDecoration(labelText: 'Email Address'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = _nameCtrl.text.trim();
              final email = _emailCtrl.text.trim();
              if (name.isNotEmpty && email.isNotEmpty) {
                try {
                  if (firebaseConfigured) {
                    await ref.read(firebaseRepositoryProvider).saveDeveloper(name: name, email: email);
                  } else {
                    final newDev = DeveloperModel(
                      id: 'dev_${DateTime.now().millisecondsSinceEpoch}',
                      userId: 'user_dev_${DateTime.now().millisecondsSinceEpoch}',
                      name: name,
                      email: email,
                      isActive: true,
                      assignedCount: 0,
                      completedCount: 0,
                      createdAt: DateTime.now(),
                    );
                    setState(() => MockDataService.developers.add(newDev));
                  }
                  _nameCtrl.clear();
                  _emailCtrl.clear();
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Developer added to roster')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.error,
                        content: Text(firebaseErrorMessage(e)),
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Add Developer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final developers = ref.watch(developersProvider);

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
                    Text(
                      'CV Developer Team Management',
                      style: AppTextStyles.heading2,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage internal CV writing experts, track active task load, and review performance metrics.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _showAddDeveloperDialog,
                  icon: const Icon(Icons.person_add_outlined),
                  label: const Text('Add Developer'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Performance Cards Grid
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Active CV Developer Roster (${developers.length})',
                      style: AppTextStyles.heading4,
                    ),
                    const SizedBox(height: 16),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: developers.length,
                      separatorBuilder: (context, _) =>
                          const Divider(height: 24),
                      itemBuilder: (context, index) {
                        final dev = developers[index];
                        final completionRate = dev.assignedCount > 0
                            ? ((dev.completedCount / dev.assignedCount) * 100)
                                  .toStringAsFixed(0)
                            : '100';

                        return Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: AppColors.accent.withValues(
                                alpha: 0.1,
                              ),
                              child: Text(
                                dev.name.isNotEmpty
                                    ? dev.name[0].toUpperCase()
                                    : 'D',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.accent,
                                  fontSize: 16,
                                ),
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
                                      Text(
                                        dev.name,
                                        style: AppTextStyles.labelLarge,
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: dev.isActive
                                              ? AppColors.successLight
                                              : AppColors.errorLight,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          dev.isActive ? 'ACTIVE' : 'INACTIVE',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: dev.isActive
                                                ? AppColors.success
                                                : AppColors.error,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    dev.email,
                                    style: AppTextStyles.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Active Load: ${dev.assignedCount} tasks',
                                    style: AppTextStyles.bodySmall,
                                  ),
                                  Text(
                                    'Completed: ${dev.completedCount} CVs',
                                    style: AppTextStyles.caption,
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Performance: $completionRate%',
                                    style: AppTextStyles.labelMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  LinearProgressIndicator(
                                    value: dev.assignedCount > 0
                                        ? (dev.completedCount /
                                              dev.assignedCount)
                                        : 1.0,
                                    backgroundColor: AppColors.border,
                                    color: AppColors.success,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Switch(
                              value: dev.isActive,
                              activeThumbColor: AppColors.success,
                              onChanged: (val) async {
                                try {
                                  if (firebaseConfigured) {
                                    await ref.read(firebaseRepositoryProvider).setDeveloperActive(dev, val);
                                  } else {
                                    setState(() {
                                      MockDataService.developers[index] =
                                          DeveloperModel(
                                            id: dev.id,
                                            userId: dev.userId,
                                            name: dev.name,
                                            email: dev.email,
                                            isActive: val,
                                            assignedCount: dev.assignedCount,
                                            completedCount: dev.completedCount,
                                            createdAt: dev.createdAt,
                                          );
                                    });
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: AppColors.error,
                                        content: Text(firebaseErrorMessage(e)),
                                      ),
                                    );
                                  }
                                }
                              },
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
}
