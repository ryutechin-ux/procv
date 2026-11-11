import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/theme/responsive.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../features/user_dashboard/data/models/cv_request_model.dart';
import '../../../../services/mock_data_service.dart';

class MyCvsPage extends ConsumerStatefulWidget {
  const MyCvsPage({super.key});

  @override
  ConsumerState<MyCvsPage> createState() => _MyCvsPageState();
}

class _MyCvsPageState extends ConsumerState<MyCvsPage> {
  String _selectedFilter = 'ALL';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final allUserCvs = ref.watch(userCvRequestsProvider);

    final filteredCvs = allUserCvs.where((cv) {
      final matchesSearch = cv.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          cv.position.toLowerCase().contains(_searchQuery.toLowerCase());
      if (!matchesSearch) return false;

      if (_selectedFilter == 'ALL') return true;
      if (_selectedFilter == 'PENDING') return cv.status == 'PENDING';
      if (_selectedFilter == 'IN_PROGRESS') {
        return cv.status == 'IN_PROGRESS' || cv.status == 'ASSIGNED' || cv.status == 'UNDER_REVIEW';
      }
      if (_selectedFilter == 'APPROVED') return cv.status == 'APPROVED';
      if (_selectedFilter == 'REVISION') return cv.status == 'REVISION_REQUIRED';
      if (_selectedFilter == 'DRAFT') return cv.status == 'DRAFT';
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
                    Text('My CV Requests', style: AppTextStyles.heading2),
                    const SizedBox(height: 4),
                    Text(
                      'Track current progress, preview drafts, and download approved production resumes.',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => context.go('/dashboard/create-cv'),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('New CV Request'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Filter Tabs & Search Bar
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            onChanged: (val) => setState(() => _searchQuery = val),
                            decoration: const InputDecoration(
                              hintText: 'Search by title or target position...',
                              prefixIcon: Icon(Icons.search),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('ALL', 'All CVs (${allUserCvs.length})'),
                          const SizedBox(width: 8),
                          _buildFilterChip('PENDING', 'Pending (${allUserCvs.where((c) => c.status == 'PENDING').length})'),
                          const SizedBox(width: 8),
                          _buildFilterChip('IN_PROGRESS', 'Processing (${allUserCvs.where((c) => c.status == 'IN_PROGRESS' || c.status == 'ASSIGNED' || c.status == 'UNDER_REVIEW').length})'),
                          const SizedBox(width: 8),
                          _buildFilterChip('APPROVED', 'Approved & Ready (${allUserCvs.where((c) => c.status == 'APPROVED').length})'),
                          const SizedBox(width: 8),
                          _buildFilterChip('REVISION', 'Revision (${allUserCvs.where((c) => c.status == 'REVISION_REQUIRED').length})'),
                          const SizedBox(width: 8),
                          _buildFilterChip('DRAFT', 'Drafts (${allUserCvs.where((c) => c.status == 'DRAFT').length})'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // List of CV Cards
            if (filteredCvs.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(48),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.search_off, size: 54, color: AppColors.textTertiary),
                        const SizedBox(height: 16),
                        Text('No CV requests found', style: AppTextStyles.heading4),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your search criteria or submit a new request.',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
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
                itemCount: filteredCvs.length,
                separatorBuilder: (context, _) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return _buildCvCard(context, filteredCvs[index]);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String filterKey, String label) {
    final isSelected = _selectedFilter == filterKey;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _selectedFilter = filterKey);
      },
      selectedColor: AppColors.accent,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildCvCard(BuildContext context, CvRequestModel cv) {
    final isApproved = cv.status == 'APPROVED';
    final hasSubmission = cv.status == 'SUBMITTED_FOR_REVIEW' || isApproved;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.description, color: AppColors.accent, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              cv.title,
                              style: AppTextStyles.heading3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          StatusBadge(status: cv.status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 16,
                        runSpacing: 4,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.work_outline, size: 16, color: AppColors.textSecondary),
                              const SizedBox(width: 6),
                              Text('Position: ${cv.position}', style: AppTextStyles.bodyMedium),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.textSecondary),
                              const SizedBox(width: 6),
                              Text(
                                'Submitted: ${cv.createdAt.day}/${cv.createdAt.month}/${cv.createdAt.year}',
                                style: AppTextStyles.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),

            // Card Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Informational status note
                Expanded(
                  child: Text(
                    isApproved
                        ? '✅ Approved by Admin. Original watermark-free PDF ready.'
                        : (hasSubmission
                            ? '📄 Watermarked preview available. Awaiting admin approval.'
                            : '⏳ Handcrafted by dedicated developer in progress.'),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isApproved ? AppColors.success : AppColors.textSecondary,
                      fontWeight: isApproved ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                Wrap(
                  spacing: 10,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => context.go('/dashboard/cv/${cv.id}'),
                      icon: const Icon(Icons.visibility_outlined, size: 16),
                      label: const Text('View Details'),
                    ),
                    if (hasSubmission)
                      OutlinedButton.icon(
                        onPressed: () => _showPreviewDialog(context, cv),
                        icon: const Icon(Icons.remove_red_eye_outlined, size: 16, color: AppColors.secondary),
                        label: const Text('Preview CV'),
                      ),
                    ElevatedButton.icon(
                      onPressed: isApproved
                          ? () => _handleDownload(context, cv)
                          : null,
                      icon: const Icon(Icons.download, size: 16),
                      label: const Text('Download Original PDF'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.border,
                        disabledForegroundColor: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPreviewDialog(BuildContext context, CvRequestModel cv) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700, maxHeight: 800),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Watermarked CV Preview', style: AppTextStyles.heading3),
                        Text('Target: ${cv.position}', style: AppTextStyles.bodySmall),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(cv.personalInfo?.fullName ?? 'Candidate Name', style: AppTextStyles.heading2),
                            Text(cv.position, style: AppTextStyles.labelLarge.copyWith(color: AppColors.secondary)),
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 16),
                            Text('Professional Summary', style: AppTextStyles.heading4),
                            const SizedBox(height: 8),
                            Text(
                              cv.professionalInfo?.professionalSummary ??
                                  'Experienced professional with proven track record in developing high-impact applications.',
                              style: AppTextStyles.bodyMedium,
                            ),
                            const SizedBox(height: 24),
                            Text('Key Technologies', style: AppTextStyles.heading4),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: (cv.skills?.technicalSkills ?? ['Flutter', 'Dart', 'Firebase', 'APIs'])
                                  .map((s) => Chip(label: Text(s)))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                      // Diagonal Watermark Overlay
                      Positioned.fill(
                        child: Center(
                          child: Transform.rotate(
                            angle: -0.45,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.15),
                                border: Border.all(color: Colors.red.withValues(alpha: 0.4), width: 2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'PROCV PREVIEW - WATERMARKED\nADMIN APPROVAL PENDING',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.red.withValues(alpha: 0.6),
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close Preview'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleDownload(BuildContext context, CvRequestModel cv) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.success,
        content: Text('Downloading original CV: ${cv.title}.pdf'),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }
}

