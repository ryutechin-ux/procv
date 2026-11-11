import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/theme/responsive.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../services/mock_data_service.dart';

class CvDetailPage extends ConsumerWidget {
  final String cvId;

  const CvDetailPage({super.key, required this.cvId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allCvs = ref.watch(allCvRequestsProvider);
    final cv = allCvs.firstWhere(
      (c) => c.id == cvId,
      orElse: () => allCvs.first,
    );

    final isApproved = cv.status == 'APPROVED';
    final hasSubmission = cv.status == 'SUBMITTED_FOR_REVIEW' || isApproved;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.contentPadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back Button and Title
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
                          Text(cv.title, style: AppTextStyles.heading2),
                          const SizedBox(width: 12),
                          StatusBadge(status: cv.status),
                        ],
                      ),
                      Text(
                        'Target Position: ${cv.position} • Request ID: ${cv.id}',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (isApproved)
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.success,
                          content: Text(
                            'Downloading original production resume: ${cv.title}.pdf',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('Download Original PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // Progress Timeline Stepper
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Workflow Progression', style: AppTextStyles.heading4),
                    const SizedBox(height: 16),
                    _buildStatusProgress(cv.status),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Responsive Two-Column Layout
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column: User-Submitted Data Details
                Expanded(
                  flex: 6,
                  child: Column(
                    children: [
                      _buildSectionCard(
                        title: '1. Personal Information',
                        icon: Icons.person_outline,
                        child: Column(
                          children: [
                            _buildInfoRow(
                              'Full Name',
                              cv.personalInfo?.fullName ?? 'N/A',
                            ),
                            _buildInfoRow(
                              'Email',
                              cv.personalInfo?.email ?? 'N/A',
                            ),
                            _buildInfoRow(
                              'Phone',
                              cv.personalInfo?.phone ?? 'N/A',
                            ),
                            _buildInfoRow(
                              'Location',
                              cv.personalInfo?.location ?? 'N/A',
                            ),
                            _buildInfoRow(
                              'LinkedIn',
                              cv.personalInfo?.linkedIn ?? 'N/A',
                            ),
                            _buildInfoRow(
                              'GitHub',
                              cv.personalInfo?.github ?? 'N/A',
                            ),
                            _buildInfoRow(
                              'Portfolio',
                              cv.personalInfo?.portfolioUrl ?? 'N/A',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildSectionCard(
                        title: '2. Professional Information',
                        icon: Icons.work_outline,
                        child: Column(
                          children: [
                            _buildInfoRow(
                              'Applying Position',
                              cv.professionalInfo?.applyingPosition ??
                                  cv.position,
                            ),
                            _buildInfoRow(
                              'Current Job Title',
                              cv.professionalInfo?.currentJobTitle ?? 'N/A',
                            ),
                            _buildInfoRow(
                              'Total Experience',
                              cv.professionalInfo?.totalExperience ?? 'N/A',
                            ),
                            _buildInfoRow(
                              'Professional Summary',
                              cv.professionalInfo?.professionalSummary ?? 'N/A',
                            ),
                            _buildInfoRow(
                              'Career Objective',
                              cv.professionalInfo?.careerObjective ?? 'N/A',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildSectionCard(
                        title: '3. Work Experience (${cv.experiences.length})',
                        icon: Icons.business,
                        child: cv.experiences.isEmpty
                            ? const Text('No experience records entered.')
                            : Column(
                                children: cv.experiences.map((exp) {
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 12.0,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.circle,
                                          size: 8,
                                          color: AppColors.accent,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${exp.position} - ${exp.company}',
                                                style: AppTextStyles.labelLarge,
                                              ),
                                              Text(
                                                '${exp.startDate.year} - ${exp.isCurrentlyWorking ? "Present" : exp.endDate?.year ?? ""}',
                                                style: AppTextStyles.caption,
                                              ),
                                              if (exp.responsibilities != null)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 4,
                                                      ),
                                                  child: Text(
                                                    exp.responsibilities!,
                                                    style:
                                                        AppTextStyles.bodySmall,
                                                  ),
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
                        title: '4. Education (${cv.education.length})',
                        icon: Icons.school_outlined,
                        child: cv.education.isEmpty
                            ? const Text('No education records entered.')
                            : Column(
                                children: cv.education.map((edu) {
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 12.0,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.circle,
                                          size: 8,
                                          color: AppColors.secondary,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                edu.degree,
                                                style: AppTextStyles.labelLarge,
                                              ),
                                              Text(
                                                '${edu.institution} (${edu.startYear} - ${edu.endYear ?? "Present"})',
                                                style: AppTextStyles.caption,
                                              ),
                                              if (edu.cgpaOrPercentage != null)
                                                Text(
                                                  'CGPA: ${edu.cgpaOrPercentage}',
                                                  style: AppTextStyles.caption,
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
                        title: '5. Skills',
                        icon: Icons.lightbulb_outline,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              (cv.skills?.technicalSkills ??
                                      [
                                        'Flutter',
                                        'Dart',
                                        'Firebase',
                                        'REST APIs',
                                      ])
                                  .map((s) => Chip(label: Text(s)))
                                  .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),

                // Right Column: Document Preview & Developer Delivery Status
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Document Management',
                                style: AppTextStyles.heading4,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Manual CV creation lifecycle and secure PDF distribution.',
                                style: AppTextStyles.bodySmall,
                              ),
                              const SizedBox(height: 20),

                              if (isApproved)
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.successLight,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.success.withValues(
                                        alpha: 0.3,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Row(
                                        children: [
                                          Icon(
                                            Icons.verified,
                                            color: AppColors.success,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'CV Approved for Production',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.success,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Admin has finalized your resume. The original watermark-free PDF is available for download.',
                                        style: TextStyle(fontSize: 13),
                                      ),
                                      const SizedBox(height: 12),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                                const SnackBar(
                                                  backgroundColor:
                                                      AppColors.success,
                                                  content: Text(
                                                    'Downloading original resume PDF...',
                                                  ),
                                                ),
                                              );
                                        },
                                        icon: const Icon(Icons.download),
                                        label: const Text(
                                          'Download Original PDF',
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.success,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else if (hasSubmission)
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.warningLight,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.warning.withValues(
                                        alpha: 0.3,
                                      ),
                                    ),
                                  ),
                                  child: const Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.hourglass_top,
                                            color: AppColors.warning,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Under Final Admin Review',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.warning,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Developer has uploaded the draft. You can view the watermarked version below. Original PDF download will unlock as soon as admin approves.',
                                        style: TextStyle(fontSize: 13),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceVariant,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: const Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.brush_outlined,
                                            color: AppColors.accent,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Manual Creation In Progress',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Our dedicated CV team is actively designing and tailoring your resume according to industry standards.',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 24),

                              // Watermarked Preview Mock Sheet
                              Text(
                                'Watermarked Draft Preview',
                                style: AppTextStyles.labelLarge,
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: 380,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Stack(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            cv.personalInfo?.fullName ??
                                                'John Doe',
                                            style: AppTextStyles.heading3,
                                          ),
                                          Text(
                                            cv.position,
                                            style: TextStyle(
                                              color: AppColors.secondary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const Divider(height: 24),
                                          Text(
                                            'PROFESSIONAL PROFILE',
                                            style: AppTextStyles.labelSmall,
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            cv
                                                    .professionalInfo
                                                    ?.professionalSummary ??
                                                'Proven track record in high-impact software engineering with deep domain expertise.',
                                            style: AppTextStyles.caption,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'CORE EXPERIENCES',
                                            style: AppTextStyles.labelSmall,
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            '• Lead Engineer at TechCorp Solutions',
                                            style: AppTextStyles.caption,
                                          ),
                                          Text(
                                            '• Scaled cross-platform architecture to 1M+ downloads',
                                            style: AppTextStyles.caption,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'EDUCATION',
                                            style: AppTextStyles.labelSmall,
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            '• B.Tech in Computer Science',
                                            style: AppTextStyles.caption,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Positioned.fill(
                                      child: Center(
                                        child: Transform.rotate(
                                          angle: -0.45,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.red.withValues(
                                                alpha: 0.12,
                                              ),
                                              border: Border.all(
                                                color: Colors.red.withValues(
                                                  alpha: 0.3,
                                                ),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              'PROCV - WATERMARKED DRAFT',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w900,
                                                color: Colors.red.withValues(
                                                  alpha: 0.5,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusProgress(String status) {
    int activeIdx = 0;
    if (status == 'PENDING') activeIdx = 1;
    if (status == 'ASSIGNED') activeIdx = 2;
    if (status == 'IN_PROGRESS') activeIdx = 3;
    if (status == 'SUBMITTED_FOR_REVIEW') activeIdx = 4;
    if (status == 'APPROVED' || status == 'COMPLETED') activeIdx = 5;

    final steps = [
      'Draft',
      'Pending',
      'Assigned',
      'In Progress',
      'Under Review',
      'Approved',
    ];

    return Row(
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          final stepIndex = index ~/ 2;
          final isDone = stepIndex < activeIdx;
          return Expanded(
            child: Container(
              height: 2,
              color: isDone ? AppColors.success : AppColors.border,
            ),
          );
        } else {
          final stepIndex = index ~/ 2;
          final isPassed = stepIndex <= activeIdx;
          final isCurrent = stepIndex == activeIdx;

          return Column(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: isCurrent
                    ? AppColors.accent
                    : (isPassed ? AppColors.success : AppColors.border),
                child: isPassed && !isCurrent
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : Text(
                        '${stepIndex + 1}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isCurrent
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 6),
              Text(
                steps[stepIndex],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  color: isCurrent ? AppColors.accent : AppColors.textSecondary,
                ),
              ),
            ],
          );
        }
      }),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: AppColors.accent),
                const SizedBox(width: 10),
                Text(title, style: AppTextStyles.labelLarge),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(child: Text(value, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }
}
