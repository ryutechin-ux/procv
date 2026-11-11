import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/theme/responsive.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../services/mock_data_service.dart';

class WorkDetailPage extends ConsumerWidget {
  final String assignmentId;

  const WorkDetailPage({super.key, required this.assignmentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignments = ref.watch(allWorkAssignmentsProvider);
    final wa = assignments.firstWhere(
      (a) => a.id == assignmentId,
      orElse: () => assignments.first,
    );

    final cvList = ref.watch(allCvRequestsProvider);
    final cv = cvList.firstWhere(
      (c) => c.id == wa.cvRequestId,
      orElse: () => cvList.first,
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Task: ${cv.title}', style: AppTextStyles.heading2),
                          const SizedBox(width: 12),
                          StatusBadge(status: wa.status),
                        ],
                      ),
                      Text('Candidate: ${wa.userName} • Target: ${wa.cvPosition}', style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => context.go('/developer/submit/${wa.id}'),
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Proceed to CV Upload'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Admin Instructions Banner
            if (wa.instructions != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.warningLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.warning, size: 28),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('ADMIN INSTRUCTIONS & PRIORITY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.warning)),
                          const SizedBox(height: 4),
                          Text(wa.instructions!, style: AppTextStyles.bodyMedium),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),

            // Candidate Information Layout
            _buildSectionCard(
              title: 'Personal Information',
              icon: Icons.person_outline,
              child: Column(
                children: [
                  _buildDetailRow('Full Name', cv.personalInfo?.fullName ?? 'N/A'),
                  _buildDetailRow('Email Address', cv.personalInfo?.email ?? 'N/A'),
                  _buildDetailRow('Phone Number', cv.personalInfo?.phone ?? 'N/A'),
                  _buildDetailRow('Current Location', cv.personalInfo?.location ?? 'N/A'),
                  _buildDetailRow('LinkedIn Profile', cv.personalInfo?.linkedIn ?? 'N/A'),
                  _buildDetailRow('GitHub Profile', cv.personalInfo?.github ?? 'N/A'),
                  _buildDetailRow('Portfolio URL', cv.personalInfo?.portfolioUrl ?? 'N/A'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _buildSectionCard(
              title: 'Professional Details & Career Objective',
              icon: Icons.work_outline,
              child: Column(
                children: [
                  _buildDetailRow('Target Applying Position', cv.professionalInfo?.applyingPosition ?? cv.position),
                  _buildDetailRow('Current Job Title', cv.professionalInfo?.currentJobTitle ?? 'N/A'),
                  _buildDetailRow('Total Experience', cv.professionalInfo?.totalExperience ?? 'N/A'),
                  _buildDetailRow('Professional Summary', cv.professionalInfo?.professionalSummary ?? 'N/A'),
                  _buildDetailRow('Career Objective', cv.professionalInfo?.careerObjective ?? 'N/A'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _buildSectionCard(
              title: 'Work Experiences (${cv.experiences.length})',
              icon: Icons.business,
              child: cv.experiences.isEmpty
                  ? const Text('No experiences recorded.')
                  : Column(
                      children: cv.experiences.map((exp) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.circle, size: 8, color: AppColors.accent),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${exp.position} at ${exp.company}', style: AppTextStyles.labelLarge),
                                    Text(
                                      '${exp.startDate.year} - ${exp.isCurrentlyWorking ? "Present" : exp.endDate?.year ?? ""}',
                                      style: AppTextStyles.caption,
                                    ),
                                    if (exp.responsibilities != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4.0),
                                        child: Text(exp.responsibilities!, style: AppTextStyles.bodySmall),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ),
            const SizedBox(height: 16),

            _buildSectionCard(
              title: 'Education & Certifications',
              icon: Icons.school_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...cv.education.map((edu) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text('• ${edu.degree} — ${edu.institution} (${edu.startYear} - ${edu.endYear ?? "Present"})'),
                    );
                  }),
                  if (cv.additionalInfo?.certifications.isNotEmpty == true) ...[
                    const SizedBox(height: 12),
                    Text('Certifications:', style: AppTextStyles.labelMedium),
                    const SizedBox(height: 4),
                    Text(cv.additionalInfo!.certifications.join(', ')),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            _buildSectionCard(
              title: 'Skills & Technical Competencies',
              icon: Icons.code,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (cv.skills?.technicalSkills ?? ['Flutter', 'Dart', 'Firebase'])
                    .map((s) => Chip(label: Text(s)))
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),

            _buildSectionCard(
              title: 'Featured Projects (${cv.projects.length})',
              icon: Icons.rocket_launch_outlined,
              child: Column(
                children: cv.projects.map((p) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.folder_special_outlined, color: AppColors.accent, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.name, style: AppTextStyles.labelLarge),
                              if (p.description != null) Text(p.description!, style: AppTextStyles.bodySmall),
                              const SizedBox(height: 4),
                              Text('Stack: ${p.technologies.join(', ')}', style: AppTextStyles.caption),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 32),

            Center(
              child: ElevatedButton.icon(
                onPressed: () => context.go('/developer/submit/${wa.id}'),
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Next: Prepare & Submit Crafted CV'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required Widget child}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: AppColors.accent),
                const SizedBox(width: 10),
                Text(title, style: AppTextStyles.heading4),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180,
            child: Text(label, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(value, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }
}

