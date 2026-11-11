/// CV Request model - stores all the information submitted by a user
class CvRequestModel {
  final String id;
  final String userId;
  final String title;
  final String position;
  final String status;
  final bool isDraft;
  final PersonalInfo? personalInfo;
  final ProfessionalInfo? professionalInfo;
  final List<WorkExperience> experiences;
  final List<Education> education;
  final SkillSet? skills;
  final List<Project> projects;
  final AdditionalInfo? additionalInfo;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const CvRequestModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.position,
    this.status = 'DRAFT',
    this.isDraft = true,
    this.personalInfo,
    this.professionalInfo,
    this.experiences = const [],
    this.education = const [],
    this.skills,
    this.projects = const [],
    this.additionalInfo,
    required this.createdAt,
    this.updatedAt,
  });

  CvRequestModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? position,
    String? status,
    bool? isDraft,
    PersonalInfo? personalInfo,
    ProfessionalInfo? professionalInfo,
    List<WorkExperience>? experiences,
    List<Education>? education,
    SkillSet? skills,
    List<Project>? projects,
    AdditionalInfo? additionalInfo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CvRequestModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      position: position ?? this.position,
      status: status ?? this.status,
      isDraft: isDraft ?? this.isDraft,
      personalInfo: personalInfo ?? this.personalInfo,
      professionalInfo: professionalInfo ?? this.professionalInfo,
      experiences: experiences ?? this.experiences,
      education: education ?? this.education,
      skills: skills ?? this.skills,
      projects: projects ?? this.projects,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class PersonalInfo {
  final String fullName;
  final String email;
  final String? phone;
  final String? location;
  final String? linkedIn;
  final String? github;
  final String? portfolioUrl;
  final String? profileImageUrl;

  const PersonalInfo({
    required this.fullName,
    required this.email,
    this.phone,
    this.location,
    this.linkedIn,
    this.github,
    this.portfolioUrl,
    this.profileImageUrl,
  });
}

class ProfessionalInfo {
  final String applyingPosition;
  final String? currentJobTitle;
  final String? professionalSummary;
  final String? totalExperience;
  final String? careerObjective;

  const ProfessionalInfo({
    required this.applyingPosition,
    this.currentJobTitle,
    this.professionalSummary,
    this.totalExperience,
    this.careerObjective,
  });
}

class WorkExperience {
  final String id;
  final String company;
  final String position;
  final DateTime startDate;
  final DateTime? endDate;
  final String? responsibilities;
  final bool isCurrentlyWorking;

  const WorkExperience({
    required this.id,
    required this.company,
    required this.position,
    required this.startDate,
    this.endDate,
    this.responsibilities,
    this.isCurrentlyWorking = false,
  });
}

class Education {
  final String id;
  final String degree;
  final String institution;
  final String? university;
  final int startYear;
  final int? endYear;
  final String? cgpaOrPercentage;

  const Education({
    required this.id,
    required this.degree,
    required this.institution,
    this.university,
    required this.startYear,
    this.endYear,
    this.cgpaOrPercentage,
  });
}

class SkillSet {
  final List<String> technicalSkills;
  final List<String> programmingLanguages;
  final List<String> frameworks;
  final List<String> tools;
  final List<String> softSkills;

  const SkillSet({
    this.technicalSkills = const [],
    this.programmingLanguages = const [],
    this.frameworks = const [],
    this.tools = const [],
    this.softSkills = const [],
  });
}

class Project {
  final String id;
  final String name;
  final String? description;
  final List<String> technologies;
  final String? projectUrl;
  final String? githubUrl;

  const Project({
    required this.id,
    required this.name,
    this.description,
    this.technologies = const [],
    this.projectUrl,
    this.githubUrl,
  });
}

class AdditionalInfo {
  final List<String> certifications;
  final List<String> achievements;
  final List<String> languages;
  final List<String> hobbies;
  final String? additionalNotes;

  const AdditionalInfo({
    this.certifications = const [],
    this.achievements = const [],
    this.languages = const [],
    this.hobbies = const [],
    this.additionalNotes,
  });
}

