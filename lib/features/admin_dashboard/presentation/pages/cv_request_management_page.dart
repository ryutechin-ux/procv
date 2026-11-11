import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/theme/responsive.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../services/mock_data_service.dart';

class CvRequestManagementPage extends ConsumerStatefulWidget {
  const CvRequestManagementPage({super.key});

  @override
  ConsumerState<CvRequestManagementPage> createState() =>
      _CvRequestManagementPageState();
}

class _CvRequestManagementPageState
    extends ConsumerState<CvRequestManagementPage> {
  String _selectedStatus = 'ALL';
  String _searchPosition = '';

  @override
  Widget build(BuildContext context) {
    final allRequests = ref.watch(allCvRequestsProvider);

    final filtered = allRequests.where((cv) {
      final matchesPos =
          cv.position.toLowerCase().contains(_searchPosition.toLowerCase()) ||
          cv.title.toLowerCase().contains(_searchPosition.toLowerCase());
      if (!matchesPos) return false;
      if (_selectedStatus != 'ALL' && cv.status != _selectedStatus) {
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
                    Text(
                      'CV Request Management',
                      style: AppTextStyles.heading2,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Comprehensive repository of all user submitted resume requests and production pipelines.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => context.go('/admin/assign-work'),
                  icon: const Icon(Icons.assignment_ind),
                  label: const Text('Open Work Assignment Wizard'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Search and Status Filters
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      onChanged: (val) => setState(() => _searchPosition = val),
                      decoration: const InputDecoration(
                        hintText: 'Filter by job position or CV title...',
                        prefixIcon: Icon(Icons.search),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(
                            'ALL',
                            'All Requests (${allRequests.length})',
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip('PENDING', 'Pending Assignment'),
                          const SizedBox(width: 8),
                          _buildFilterChip('ASSIGNED', 'Assigned'),
                          const SizedBox(width: 8),
                          _buildFilterChip('IN_PROGRESS', 'In Progress'),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            'SUBMITTED_FOR_REVIEW',
                            'Under Review',
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            'REVISION_REQUIRED',
                            'Revision Required',
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip('APPROVED', 'Approved'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // List of Requests
            if (filtered.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Text(
                      'No CV requests match the criteria.',
                      style: AppTextStyles.bodyLarge,
                    ),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                separatorBuilder: (context, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final cv = filtered[index];
                  final isPending = cv.status == 'PENDING';

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.file_copy_outlined,
                              color: AppColors.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      cv.title,
                                      style: AppTextStyles.labelLarge,
                                    ),
                                    const SizedBox(width: 8),
                                    StatusBadge(status: cv.status),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Candidate: ${cv.personalInfo?.fullName ?? "Candidate"} • Target: ${cv.position} • Req ID: ${cv.id}',
                                  style: AppTextStyles.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Submitted: ${cv.createdAt.day}/${cv.createdAt.month}/${cv.createdAt.year}',
                              style: AppTextStyles.caption,
                            ),
                          ),
                          Wrap(
                            spacing: 8,
                            children: [
                              OutlinedButton(
                                onPressed: () =>
                                    context.go('/dashboard/cv/${cv.id}'),
                                child: const Text('View Full CV'),
                              ),
                              if (isPending)
                                ElevatedButton.icon(
                                  onPressed: () =>
                                      context.go('/admin/assign-work'),
                                  icon: const Icon(Icons.person_add, size: 16),
                                  label: const Text('Assign Developer'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.accent,
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

  Widget _buildFilterChip(String key, String label) {
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
}
