import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/theme/responsive.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../features/developer_dashboard/data/models/work_assignment_model.dart';
import '../../../../services/mock_data_service.dart';

class AssignedWorksPage extends ConsumerStatefulWidget {
  const AssignedWorksPage({super.key});

  @override
  ConsumerState<AssignedWorksPage> createState() => _AssignedWorksPageState();
}

class _AssignedWorksPageState extends ConsumerState<AssignedWorksPage> {
  final String _selectedPriority = 'ALL';
  String _selectedStatus = 'ALL';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final myAssignments = ref.watch(developerAssignmentsProvider);

    final filtered = myAssignments.where((item) {
      final matchesSearch =
          item.userName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.cvPosition.toLowerCase().contains(_searchQuery.toLowerCase());
      if (!matchesSearch) return false;

      if (_selectedPriority != 'ALL' && item.priority != _selectedPriority) {
        return false;
      }
      if (_selectedStatus != 'ALL' && item.status != _selectedStatus) {
        return false;
      }

      return true;
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
                    Text('Assigned CV Tasks', style: AppTextStyles.heading2),
                    const SizedBox(height: 4),
                    Text(
                      'All candidate resume preparation tasks assigned to your developer queue.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Filter bar
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: const InputDecoration(
                        hintText:
                            'Search by candidate name or target position...',
                        prefixIcon: Icon(Icons.search),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildStatusChip('ALL', 'All Statuses'),
                              _buildStatusChip('ASSIGNED', 'Assigned'),
                              _buildStatusChip('IN_PROGRESS', 'In Progress'),
                              _buildStatusChip(
                                'REVISION_REQUIRED',
                                'Revision Required',
                              ),
                              _buildStatusChip(
                                'SUBMITTED_FOR_REVIEW',
                                'Submitted',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            if (filtered.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(48),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.assignment_turned_in_outlined,
                          size: 48,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No matching assigned works',
                          style: AppTextStyles.heading4,
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
                itemCount: filtered.length,
                separatorBuilder: (context, _) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return _buildWorkCard(context, filtered[index]);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String key, String label) {
    final isSelected = _selectedStatus == key;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _selectedStatus = key);
      },
      selectedColor: AppColors.accent,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildWorkCard(BuildContext context, WorkAssignmentModel item) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.accent.withValues(alpha: 0.1),
                  child: Text(
                    item.userName.isNotEmpty
                        ? item.userName[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(item.userName, style: AppTextStyles.heading4),
                          const SizedBox(width: 8),
                          _buildPriorityBadge(item.priority),
                          const SizedBox(width: 8),
                          StatusBadge(status: item.status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Target Position: ${item.cvPosition} • Assigned: ${item.assignedAt.day}/${item.assignedAt.month}/${item.assignedAt.year}',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (item.instructions != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Admin Instructions: ${item.instructions}',
                  style: AppTextStyles.bodySmall,
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => context.go('/developer/work/${item.id}'),
                  icon: const Icon(Icons.person_search_outlined, size: 16),
                  label: const Text('Review Candidate Details'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => context.go('/developer/submit/${item.id}'),
                  icon: const Icon(Icons.upload_file, size: 16),
                  label: const Text('Submit Handcrafted CV'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(String priority) {
    Color color = AppColors.secondary;
    if (priority == 'URGENT') color = AppColors.error;
    if (priority == 'HIGH') color = AppColors.warning;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$priority PRIORITY',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
