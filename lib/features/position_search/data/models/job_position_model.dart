/// Job position model for position search feature
class JobPositionModel {
  final String id;
  final String title;
  final String? category;
  final List<String> relatedSkills;
  final int searchCount;

  const JobPositionModel({
    required this.id,
    required this.title,
    this.category,
    this.relatedSkills = const [],
    this.searchCount = 0,
  });
}

