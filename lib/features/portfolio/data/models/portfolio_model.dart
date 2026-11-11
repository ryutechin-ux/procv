/// Portfolio model for user portfolio management
class PortfolioModel {
  final String id;
  final String userId;
  final String title;
  final String? bio;
  final String? profileImageUrl;
  final Map<String, String> socialLinks;
  final List<PortfolioProject> projects;
  final List<String> skills;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const PortfolioModel({
    required this.id,
    required this.userId,
    required this.title,
    this.bio,
    this.profileImageUrl,
    this.socialLinks = const {},
    this.projects = const [],
    this.skills = const [],
    required this.createdAt,
    this.updatedAt,
  });
}

class PortfolioProject {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final List<String> technologies;
  final String? liveUrl;
  final String? githubUrl;

  const PortfolioProject({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.technologies = const [],
    this.liveUrl,
    this.githubUrl,
  });
}

