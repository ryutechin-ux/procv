import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/theme/responsive.dart';
import '../../../../features/portfolio/data/models/portfolio_model.dart';
import '../../../../firebase_bootstrap.dart';
import '../../../../services/mock_data_service.dart';

class PortfoliosPage extends ConsumerStatefulWidget {
  const PortfoliosPage({super.key});

  @override
  ConsumerState<PortfoliosPage> createState() => _PortfoliosPageState();
}

class _PortfoliosPageState extends ConsumerState<PortfoliosPage> {
  Future<void> _deletePortfolio(String id) async {
    try {
      if (firebaseConfigured) {
        await ref.read(firebaseRepositoryProvider).deletePortfolio(id);
      } else {
        setState(() {
          MockDataService.portfolios.removeWhere((p) => p.id == id);
        });
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Portfolio removed successfully')),
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

  void _showPortfolioPreview(BuildContext context, PortfolioModel p) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800, maxHeight: 850),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Live Web Portfolio Preview',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: AppColors.accent,
                          child: Text(
                            p.title.isNotEmpty ? p.title[0].toUpperCase() : 'P',
                            style: const TextStyle(
                              fontSize: 32,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          p.title,
                          style: AppTextStyles.heading2,
                          textAlign: TextAlign.center,
                        ),
                        if (p.bio != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            p.bio!,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        const SizedBox(height: 16),
                        // Social Links
                        Wrap(
                          spacing: 12,
                          children: p.socialLinks.entries.map((entry) {
                            return ActionChip(
                              avatar: const Icon(Icons.link, size: 14),
                              label: Text('${entry.key}: ${entry.value}'),
                              onPressed: () {},
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 20),

                  // Skills
                  Text('Core Proficiencies', style: AppTextStyles.heading4),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: p.skills
                        .map((s) => Chip(label: Text(s)))
                        .toList(),
                  ),
                  const SizedBox(height: 28),

                  // Projects
                  Text(
                    'Showcase Projects (${p.projects.length})',
                    style: AppTextStyles.heading4,
                  ),
                  const SizedBox(height: 16),
                  ...p.projects.map((proj) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(proj.name, style: AppTextStyles.labelLarge),
                            if (proj.description != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                proj.description!,
                                style: AppTextStyles.bodySmall,
                              ),
                            ],
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              children: proj.technologies
                                  .map(
                                    (t) => Chip(
                                      label: Text(
                                        t,
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final portfolios = ref.watch(userPortfoliosProvider);

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
                    Text('My Portfolios', style: AppTextStyles.heading2),
                    const SizedBox(height: 4),
                    Text(
                      'Create and host modern multi-project developer portfolios to showcase your work online.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => context.go('/dashboard/portfolios/create'),
                  icon: const Icon(Icons.add),
                  label: const Text('Create New Portfolio'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            if (portfolios.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(48),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.badge_outlined,
                          size: 54,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No portfolios created yet',
                          style: AppTextStyles.heading4,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'You can manage multiple customized portfolios for different industries.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () =>
                              context.go('/dashboard/portfolios/create'),
                          child: const Text('Create Your First Portfolio'),
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
                itemCount: portfolios.length,
                separatorBuilder: (context, _) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final p = portfolios[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.web,
                                  color: AppColors.accent,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p.title,
                                      style: AppTextStyles.heading3,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${p.projects.length} Projects • ${p.skills.length} Skills • Created: ${p.createdAt.day}/${p.createdAt.month}/${p.createdAt.year}',
                                      style: AppTextStyles.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (p.bio != null) ...[
                            const SizedBox(height: 12),
                            Text(p.bio!, style: AppTextStyles.bodyMedium),
                          ],
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            children: p.skills
                                .map((s) => Chip(label: Text(s)))
                                .toList(),
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () =>
                                    _showPortfolioPreview(context, p),
                                icon: const Icon(
                                  Icons.remove_red_eye_outlined,
                                  size: 16,
                                ),
                                label: const Text('Preview Live Page'),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton.icon(
                                onPressed: () => _deletePortfolio(p.id),
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 16,
                                  color: AppColors.error,
                                ),
                                label: const Text(
                                  'Delete',
                                  style: TextStyle(color: AppColors.error),
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
}
