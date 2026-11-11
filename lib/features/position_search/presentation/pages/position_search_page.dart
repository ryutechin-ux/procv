import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/theme/responsive.dart';
import '../../../../features/position_search/data/models/job_position_model.dart';
import '../../../../services/mock_data_service.dart';

class PositionSearchPage extends ConsumerStatefulWidget {
  const PositionSearchPage({super.key});

  @override
  ConsumerState<PositionSearchPage> createState() => _PositionSearchPageState();
}

class _PositionSearchPageState extends ConsumerState<PositionSearchPage> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'ALL';
  final List<String> _recentSearches = ['Flutter Developer', 'UI/UX Designer', 'Backend Developer'];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _executeSearch(String query) {
    setState(() {
      _searchQuery = query;
      _searchCtrl.text = query;
      if (query.isNotEmpty && !_recentSearches.contains(query)) {
        _recentSearches.insert(0, query);
        if (_recentSearches.length > 5) _recentSearches.removeLast();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final positions = ref.watch(jobPositionsProvider);

    final filteredPositions = positions.where((p) {
      final matchesQuery = p.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.relatedSkills.any((s) => s.toLowerCase().contains(_searchQuery.toLowerCase()));
      if (!matchesQuery) return false;
      if (_selectedCategory != 'ALL' && p.category != _selectedCategory) return false;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.contentPadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Explore Job Positions & Career Tracks', style: AppTextStyles.heading2),
            const SizedBox(height: 4),
            Text(
              'Browse specialized industry positions, explore required technical skills, and generate a tailored CV request.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),

            // Search Banner
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _searchCtrl,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      onSubmitted: _executeSearch,
                      decoration: InputDecoration(
                        hintText: 'Search by title (e.g. Flutter Developer) or skill (e.g. Firebase, Python)...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Recently Searched & Popular tags
                    Row(
                      children: [
                        Text('Recent Searches:', style: AppTextStyles.caption),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: _recentSearches.map((tag) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 6.0),
                                  child: ActionChip(
                                    label: Text(tag, style: const TextStyle(fontSize: 11)),
                                    onPressed: () => _executeSearch(tag),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Category filters
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildCatChip('ALL', 'All Tracks'),
                          const SizedBox(width: 8),
                          _buildCatChip('Mobile', 'Mobile App'),
                          const SizedBox(width: 8),
                          _buildCatChip('Frontend', 'Frontend'),
                          const SizedBox(width: 8),
                          _buildCatChip('Backend', 'Backend'),
                          const SizedBox(width: 8),
                          _buildCatChip('Design', 'UI/UX Design'),
                          const SizedBox(width: 8),
                          _buildCatChip('General', 'Software Engineering'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text('Available Positions (${filteredPositions.length})', style: AppTextStyles.heading3),
            const SizedBox(height: 16),

            // Grid of Positions
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = Responsive.dashboardCrossAxisCount(context);
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount > 2 ? 3 : (crossAxisCount == 2 ? 2 : 1),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.4,
                  ),
                  itemCount: filteredPositions.length,
                  itemBuilder: (context, index) {
                    final pos = filteredPositions[index];
                    return _buildPositionCard(context, pos);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCatChip(String cat, String label) {
    final isSelected = _selectedCategory == cat;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) setState(() => _selectedCategory = cat);
      },
      selectedColor: AppColors.accent,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildPositionCard(BuildContext context, JobPositionModel pos) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.work_outline, color: AppColors.accent, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(pos.title, style: AppTextStyles.labelLarge),
                      Text('Track: ${pos.category ?? "General"}', style: AppTextStyles.caption),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Associated Keywords & Skills:', style: AppTextStyles.caption),
            const SizedBox(height: 6),
            Expanded(
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children: pos.relatedSkills.map((s) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(s, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500)),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.go('/dashboard/create-cv');
                },
                icon: const Icon(Icons.post_add, size: 16),
                label: const Text('Apply for this CV'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

