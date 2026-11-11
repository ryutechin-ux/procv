import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/theme/responsive.dart';
import '../../../../features/portfolio/data/models/portfolio_model.dart';
import '../../../../firebase_bootstrap.dart';
import '../../../../services/mock_data_service.dart';

class CreatePortfolioPage extends ConsumerStatefulWidget {
  const CreatePortfolioPage({super.key});

  @override
  ConsumerState<CreatePortfolioPage> createState() => _CreatePortfolioPageState();
}

class _CreatePortfolioPageState extends ConsumerState<CreatePortfolioPage> {
  bool _isSaving = false;
  final _titleCtrl = TextEditingController(text: 'Senior Full Stack Engineer Portfolio');
  final _bioCtrl = TextEditingController(
      text: 'Passionate developer crafting modern cloud applications and high performance mobile experiences.');
  final _githubCtrl = TextEditingController(text: 'https://github.com/johndoe');
  final _linkedinCtrl = TextEditingController(text: 'https://linkedin.com/in/johndoe');
  final _twitterCtrl = TextEditingController(text: 'https://twitter.com/johndoe');

  final List<String> _skills = ['Flutter', 'Dart', 'Firebase', 'TypeScript', 'Node.js', 'Docker', 'GraphQL'];
  final _skillInputCtrl = TextEditingController();

  final List<PortfolioProject> _projects = [
    const PortfolioProject(
      id: '1',
      name: 'OmniCloud - Serverless Backend Engine',
      description: 'Distributed microservice engine scaling across multi-region clusters.',
      technologies: ['Dart', 'Docker', 'GCP'],
      liveUrl: 'https://omnicloud.example.com',
      githubUrl: 'https://github.com/johndoe/omnicloud',
    ),
  ];

  final _projNameCtrl = TextEditingController();
  final _projDescCtrl = TextEditingController();
  final _projTechCtrl = TextEditingController();
  final _projUrlCtrl = TextEditingController();
  final _projGitCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bioCtrl.dispose();
    _githubCtrl.dispose();
    _linkedinCtrl.dispose();
    _twitterCtrl.dispose();
    _skillInputCtrl.dispose();
    _projNameCtrl.dispose();
    _projDescCtrl.dispose();
    _projTechCtrl.dispose();
    _projUrlCtrl.dispose();
    _projGitCtrl.dispose();
    super.dispose();
  }

  Future<void> _savePortfolio() async {
    if (_isSaving) return;

    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a portfolio title')),
      );
      return;
    }

    final user = ref.read(currentUserProvider);
    final firebaseAuthUser = firebaseConfigured ? FirebaseAuth.instance.currentUser : null;
    final userId = firebaseAuthUser?.uid ?? user?.uid ?? 'user_001';

    setState(() => _isSaving = true);

    final newPortfolio = PortfolioModel(
      id: 'portfolio_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      title: _titleCtrl.text.trim(),
      bio: _bioCtrl.text.trim(),
      socialLinks: {
        'github': _githubCtrl.text.trim(),
        'linkedin': _linkedinCtrl.text.trim(),
        'twitter': _twitterCtrl.text.trim(),
      },
      skills: _skills,
      projects: _projects,
      createdAt: DateTime.now(),
    );

    try {
      if (firebaseConfigured && firebaseAuthUser != null) {
        await ref.read(firebaseRepositoryProvider).savePortfolio(newPortfolio);
      } else {
        setState(() {
      }
      setState(() {
        final existingIdx = MockDataService.portfolios.indexWhere((p) => p.id == newPortfolio.id);
        if (existingIdx >= 0) {
          MockDataService.portfolios[existingIdx] = newPortfolio;
        } else {
          MockDataService.portfolios.insert(0, newPortfolio);
        });
        if (firebaseConfigured && firebaseAuthUser == null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.warning,
              content: Text('Saved locally. Sign in with a Firebase account to persist data in Firebase.'),
            ),
          );
        }
      });
      if (firebaseConfigured && firebaseAuthUser == null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.warning,
            content: Text('Saved locally. Sign in with a Firebase account to persist data in Firebase.'),
          ),
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.success,
          content: Text('Portfolio created and published successfully!'),
        ),
      );
      context.go('/dashboard/portfolios');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          content: Text(firebaseErrorMessage(e)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showAddProjectDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Showcase Project'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _projNameCtrl, decoration: const InputDecoration(labelText: 'Project Name')),
              const SizedBox(height: 12),
              TextField(controller: _projDescCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Description')),
              const SizedBox(height: 12),
              TextField(controller: _projTechCtrl, decoration: const InputDecoration(labelText: 'Tech Stack (comma separated)')),
              const SizedBox(height: 12),
              TextField(controller: _projUrlCtrl, decoration: const InputDecoration(labelText: 'Live Demo URL')),
              const SizedBox(height: 12),
              TextField(controller: _projGitCtrl, decoration: const InputDecoration(labelText: 'GitHub Repository URL')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (_projNameCtrl.text.isNotEmpty) {
                setState(() {
                  _projects.add(
                    PortfolioProject(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: _projNameCtrl.text.trim(),
                      description: _projDescCtrl.text.trim(),
                      technologies: _projTechCtrl.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList(),
                      liveUrl: _projUrlCtrl.text.trim(),
                      githubUrl: _projGitCtrl.text.trim(),
                    ),
                  );
                });
                _projNameCtrl.clear();
                _projDescCtrl.clear();
                _projTechCtrl.clear();
                Navigator.pop(context);
              }
            },
            child: const Text('Add Project'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    Text('Create Developer Portfolio', style: AppTextStyles.heading2),
                    Text('Showcase your software artifacts, technical competencies, and contact channels.', style: AppTextStyles.bodySmall),
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
                      Text('1. Profile Information', style: AppTextStyles.heading4),
                      const SizedBox(height: 16),
                      TextField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Portfolio Title *')),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _bioCtrl,
                        maxLines: 3,
                        decoration: const InputDecoration(labelText: 'Professional Bio & Headline'),
                      ),
                      const SizedBox(height: 28),

                      Text('2. Social & Repository Links', style: AppTextStyles.heading4),
                      const SizedBox(height: 16),
                      TextField(controller: _githubCtrl, decoration: const InputDecoration(labelText: 'GitHub URL', prefixIcon: Icon(Icons.code))),
                      const SizedBox(height: 12),
                      TextField(controller: _linkedinCtrl, decoration: const InputDecoration(labelText: 'LinkedIn URL', prefixIcon: Icon(Icons.link))),
                      const SizedBox(height: 12),
                      TextField(controller: _twitterCtrl, decoration: const InputDecoration(labelText: 'Twitter / X URL', prefixIcon: Icon(Icons.alternate_email))),
                      const SizedBox(height: 28),

                      Text('3. Skills & Technologies', style: AppTextStyles.heading4),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ..._skills.map((s) => Chip(
                                label: Text(s),
                                onDeleted: () => setState(() => _skills.remove(s)),
                              )),
                          ActionChip(
                            avatar: const Icon(Icons.add, size: 16),
                            label: const Text('Add Skill'),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Add Skill'),
                                  content: TextField(
                                    controller: _skillInputCtrl,
                                    autofocus: true,
                                    decoration: const InputDecoration(hintText: 'Skill name'),
                                  ),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                                    ElevatedButton(
                                      onPressed: () {
                                        if (_skillInputCtrl.text.isNotEmpty) {
                                          setState(() => _skills.add(_skillInputCtrl.text.trim()));
                                          _skillInputCtrl.clear();
                                          Navigator.pop(context);
                                        }
                                      },
                                      child: const Text('Add'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('4. Featured Projects (${_projects.length})', style: AppTextStyles.heading4),
                          ElevatedButton.icon(
                            onPressed: _showAddProjectDialog,
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Add Project'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ..._projects.map((p) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.folder_outlined, color: AppColors.accent),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(p.name, style: AppTextStyles.labelLarge),
                                      if (p.description != null) Text(p.description!, style: AppTextStyles.caption),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                                  onPressed: () => setState(() => _projects.remove(p)),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 36),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isSaving ? null : _savePortfolio,
                          icon: _isSaving
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.check_circle_outline),
                          label: const Text('Publish Portfolio', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
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

