import 'package:cloud_firestore/cloud_firestore.dart';

import '../features/auth/data/models/user_model.dart';
import '../features/developer_dashboard/data/models/work_assignment_model.dart';
import '../features/notifications/data/models/notification_model.dart';
import '../features/portfolio/data/models/portfolio_model.dart';
import '../features/position_search/data/models/job_position_model.dart';
import '../features/user_dashboard/data/models/cv_request_model.dart';

DateTime firestoreDate(dynamic value, {DateTime? fallback}) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value) ?? fallback ?? DateTime.now();
  }
  return fallback ?? DateTime.now();
}

DateTime? firestoreDateOrNull(dynamic value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
  return null;
}

List<String> firestoreStrings(dynamic value) {
  if (value is! List) return const [];
  return value.map((item) => item.toString()).where((item) => item.isNotEmpty).toList();
}

Map<String, dynamic>? firestoreMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

int firestoreInt(dynamic value, [int fallback = 0]) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? fallback;
}

extension UserModelFirestore on UserModel {
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'role': role,
      'phone': phone,
      'location': location,
      'isBlocked': isBlocked,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt == null ? null : Timestamp.fromDate(updatedAt!),
    };
  }
}

UserModel userFromFirestore(String id, Map<String, dynamic> data) {
  return UserModel(
    uid: (data['uid'] as String?)?.isNotEmpty == true ? data['uid'] as String : id,
    email: data['email'] as String? ?? '',
    displayName: data['displayName'] as String? ?? '',
    photoURL: data['photoURL'] as String?,
    role: data['role'] as String? ?? 'user',
    phone: data['phone'] as String?,
    location: data['location'] as String?,
    isBlocked: data['isBlocked'] as bool? ?? false,
    createdAt: firestoreDate(data['createdAt']),
    updatedAt: firestoreDateOrNull(data['updatedAt']),
  );
}

extension CvRequestModelFirestore on CvRequestModel {
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'position': position,
      'status': status,
      'isDraft': isDraft,
      'personalInfo': personalInfo?.toFirestore(),
      'professionalInfo': professionalInfo?.toFirestore(),
      'experiences': experiences.map((item) => item.toFirestore()).toList(),
      'education': education.map((item) => item.toFirestore()).toList(),
      'skills': skills?.toFirestore(),
      'projects': projects.map((item) => item.toFirestore()).toList(),
      'additionalInfo': additionalInfo?.toFirestore(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt == null ? null : Timestamp.fromDate(updatedAt!),
    };
  }
}

CvRequestModel cvRequestFromFirestore(String id, Map<String, dynamic> data) {
  final personal = firestoreMap(data['personalInfo']);
  final professional = firestoreMap(data['professionalInfo']);
  final skills = firestoreMap(data['skills']);
  final additional = firestoreMap(data['additionalInfo']);
  return CvRequestModel(
    id: id,
    userId: data['userId'] as String? ?? '',
    title: data['title'] as String? ?? '',
    position: data['position'] as String? ?? '',
    status: data['status'] as String? ?? 'DRAFT',
    isDraft: data['isDraft'] as bool? ?? false,
    personalInfo: personal == null ? null : personalInfoFromFirestore(personal),
    professionalInfo: professional == null ? null : professionalInfoFromFirestore(professional),
    experiences: _mapList(data['experiences'], experienceFromFirestore),
    education: _mapList(data['education'], educationFromFirestore),
    skills: skills == null ? null : skillSetFromFirestore(skills),
    projects: _mapList(data['projects'], projectFromFirestore),
    additionalInfo: additional == null ? null : additionalInfoFromFirestore(additional),
    createdAt: firestoreDate(data['createdAt']),
    updatedAt: firestoreDateOrNull(data['updatedAt']),
  );
}

extension PersonalInfoFirestore on PersonalInfo {
  Map<String, dynamic> toFirestore() {
    return {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'location': location,
      'linkedIn': linkedIn,
      'github': github,
      'portfolioUrl': portfolioUrl,
      'profileImageUrl': profileImageUrl,
    };
  }
}

PersonalInfo personalInfoFromFirestore(Map<String, dynamic> data) {
  return PersonalInfo(
    fullName: data['fullName'] as String? ?? '',
    email: data['email'] as String? ?? '',
    phone: data['phone'] as String?,
    location: data['location'] as String?,
    linkedIn: data['linkedIn'] as String?,
    github: data['github'] as String?,
    portfolioUrl: data['portfolioUrl'] as String?,
    profileImageUrl: data['profileImageUrl'] as String?,
  );
}

extension ProfessionalInfoFirestore on ProfessionalInfo {
  Map<String, dynamic> toFirestore() {
    return {
      'applyingPosition': applyingPosition,
      'currentJobTitle': currentJobTitle,
      'professionalSummary': professionalSummary,
      'totalExperience': totalExperience,
      'careerObjective': careerObjective,
    };
  }
}

ProfessionalInfo professionalInfoFromFirestore(Map<String, dynamic> data) {
  return ProfessionalInfo(
    applyingPosition: data['applyingPosition'] as String? ?? '',
    currentJobTitle: data['currentJobTitle'] as String?,
    professionalSummary: data['professionalSummary'] as String?,
    totalExperience: data['totalExperience'] as String?,
    careerObjective: data['careerObjective'] as String?,
  );
}

extension WorkExperienceFirestore on WorkExperience {
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'company': company,
      'position': position,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate == null ? null : Timestamp.fromDate(endDate!),
      'responsibilities': responsibilities,
      'isCurrentlyWorking': isCurrentlyWorking,
    };
  }
}

WorkExperience experienceFromFirestore(Map<String, dynamic> data) {
  return WorkExperience(
    id: data['id'] as String? ?? '',
    company: data['company'] as String? ?? '',
    position: data['position'] as String? ?? '',
    startDate: firestoreDate(data['startDate']),
    endDate: firestoreDateOrNull(data['endDate']),
    responsibilities: data['responsibilities'] as String?,
    isCurrentlyWorking: data['isCurrentlyWorking'] as bool? ?? false,
  );
}

extension EducationFirestore on Education {
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'degree': degree,
      'institution': institution,
      'university': university,
      'startYear': startYear,
      'endYear': endYear,
      'cgpaOrPercentage': cgpaOrPercentage,
    };
  }
}

Education educationFromFirestore(Map<String, dynamic> data) {
  return Education(
    id: data['id'] as String? ?? '',
    degree: data['degree'] as String? ?? '',
    institution: data['institution'] as String? ?? '',
    university: data['university'] as String?,
    startYear: firestoreInt(data['startYear']),
    endYear: data['endYear'] == null ? null : firestoreInt(data['endYear']),
    cgpaOrPercentage: data['cgpaOrPercentage'] as String?,
  );
}

extension SkillSetFirestore on SkillSet {
  Map<String, dynamic> toFirestore() {
    return {
      'technicalSkills': technicalSkills,
      'programmingLanguages': programmingLanguages,
      'frameworks': frameworks,
      'tools': tools,
      'softSkills': softSkills,
    };
  }
}

SkillSet skillSetFromFirestore(Map<String, dynamic> data) {
  return SkillSet(
    technicalSkills: firestoreStrings(data['technicalSkills']),
    programmingLanguages: firestoreStrings(data['programmingLanguages']),
    frameworks: firestoreStrings(data['frameworks']),
    tools: firestoreStrings(data['tools']),
    softSkills: firestoreStrings(data['softSkills']),
  );
}

extension ProjectFirestore on Project {
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'technologies': technologies,
      'projectUrl': projectUrl,
      'githubUrl': githubUrl,
    };
  }
}

Project projectFromFirestore(Map<String, dynamic> data) {
  return Project(
    id: data['id'] as String? ?? '',
    name: data['name'] as String? ?? '',
    description: data['description'] as String?,
    technologies: firestoreStrings(data['technologies']),
    projectUrl: data['projectUrl'] as String?,
    githubUrl: data['githubUrl'] as String?,
  );
}

extension AdditionalInfoFirestore on AdditionalInfo {
  Map<String, dynamic> toFirestore() {
    return {
      'certifications': certifications,
      'achievements': achievements,
      'languages': languages,
      'hobbies': hobbies,
      'additionalNotes': additionalNotes,
    };
  }
}

AdditionalInfo additionalInfoFromFirestore(Map<String, dynamic> data) {
  return AdditionalInfo(
    certifications: firestoreStrings(data['certifications']),
    achievements: firestoreStrings(data['achievements']),
    languages: firestoreStrings(data['languages']),
    hobbies: firestoreStrings(data['hobbies']),
    additionalNotes: data['additionalNotes'] as String?,
  );
}

extension WorkAssignmentModelFirestore on WorkAssignmentModel {
  Map<String, dynamic> toFirestore() {
    return {
      'cvRequestId': cvRequestId,
      'developerId': developerId,
      'developerName': developerName,
      'adminId': adminId,
      'priority': priority,
      'instructions': instructions,
      'status': status,
      'userName': userName,
      'cvPosition': cvPosition,
      'assignedAt': Timestamp.fromDate(assignedAt),
      'updatedAt': updatedAt == null ? null : Timestamp.fromDate(updatedAt!),
    };
  }
}

WorkAssignmentModel workAssignmentFromFirestore(String id, Map<String, dynamic> data) {
  return WorkAssignmentModel(
    id: id,
    cvRequestId: data['cvRequestId'] as String? ?? '',
    developerId: data['developerId'] as String? ?? '',
    developerName: data['developerName'] as String? ?? '',
    adminId: data['adminId'] as String? ?? '',
    priority: data['priority'] as String? ?? 'MEDIUM',
    instructions: data['instructions'] as String?,
    status: data['status'] as String? ?? 'ASSIGNED',
    userName: data['userName'] as String? ?? '',
    cvPosition: data['cvPosition'] as String? ?? '',
    assignedAt: firestoreDate(data['assignedAt']),
    updatedAt: firestoreDateOrNull(data['updatedAt']),
  );
}

extension CvSubmissionModelFirestore on CvSubmissionModel {
  Map<String, dynamic> toFirestore() {
    return {
      'cvRequestId': cvRequestId,
      'developerId': developerId,
      'watermarkedPdfUrl': watermarkedPdfUrl,
      'originalPdfUrl': originalPdfUrl,
      'notes': notes,
      'status': status,
      'submittedAt': Timestamp.fromDate(submittedAt),
      'reviewedBy': reviewedBy,
      'reviewedAt': reviewedAt == null ? null : Timestamp.fromDate(reviewedAt!),
      'revisionReason': revisionReason,
    };
  }
}

CvSubmissionModel cvSubmissionFromFirestore(String id, Map<String, dynamic> data) {
  return CvSubmissionModel(
    id: id,
    cvRequestId: data['cvRequestId'] as String? ?? '',
    developerId: data['developerId'] as String? ?? '',
    watermarkedPdfUrl: data['watermarkedPdfUrl'] as String?,
    originalPdfUrl: data['originalPdfUrl'] as String?,
    notes: data['notes'] as String?,
    status: data['status'] as String? ?? 'SUBMITTED_FOR_REVIEW',
    submittedAt: firestoreDate(data['submittedAt']),
    reviewedBy: data['reviewedBy'] as String?,
    reviewedAt: firestoreDateOrNull(data['reviewedAt']),
    revisionReason: data['revisionReason'] as String?,
  );
}

extension DeveloperModelFirestore on DeveloperModel {
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'isActive': isActive,
      'assignedCount': assignedCount,
      'completedCount': completedCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

DeveloperModel developerFromFirestore(String id, Map<String, dynamic> data) {
  return DeveloperModel(
    id: id,
    userId: data['userId'] as String? ?? '',
    name: data['name'] as String? ?? '',
    email: data['email'] as String? ?? id,
    isActive: data['isActive'] as bool? ?? true,
    assignedCount: firestoreInt(data['assignedCount']),
    completedCount: firestoreInt(data['completedCount']),
    createdAt: firestoreDate(data['createdAt']),
  );
}

extension NotificationModelFirestore on NotificationModel {
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'relatedRequestId': relatedRequestId,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

NotificationModel notificationFromFirestore(String id, Map<String, dynamic> data) {
  return NotificationModel(
    id: id,
    userId: data['userId'] as String? ?? '',
    title: data['title'] as String? ?? '',
    message: data['message'] as String? ?? '',
    type: data['type'] as String? ?? '',
    relatedRequestId: data['relatedRequestId'] as String?,
    isRead: data['isRead'] as bool? ?? false,
    createdAt: firestoreDate(data['createdAt']),
  );
}

extension PortfolioModelFirestore on PortfolioModel {
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'bio': bio,
      'profileImageUrl': profileImageUrl,
      'socialLinks': socialLinks,
      'projects': projects.map((item) => item.toFirestore()).toList(),
      'skills': skills,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt == null ? null : Timestamp.fromDate(updatedAt!),
    };
  }
}

PortfolioModel portfolioFromFirestore(String id, Map<String, dynamic> data) {
  final links = firestoreMap(data['socialLinks']) ?? {};
  return PortfolioModel(
    id: id,
    userId: data['userId'] as String? ?? '',
    title: data['title'] as String? ?? '',
    bio: data['bio'] as String?,
    profileImageUrl: data['profileImageUrl'] as String?,
    socialLinks: links.map((key, value) => MapEntry(key, value.toString())),
    projects: _mapList(data['projects'], portfolioProjectFromFirestore),
    skills: firestoreStrings(data['skills']),
    createdAt: firestoreDate(data['createdAt']),
    updatedAt: firestoreDateOrNull(data['updatedAt']),
  );
}

extension PortfolioProjectFirestore on PortfolioProject {
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'technologies': technologies,
      'liveUrl': liveUrl,
      'githubUrl': githubUrl,
    };
  }
}

PortfolioProject portfolioProjectFromFirestore(Map<String, dynamic> data) {
  return PortfolioProject(
    id: data['id'] as String? ?? '',
    name: data['name'] as String? ?? '',
    description: data['description'] as String?,
    imageUrl: data['imageUrl'] as String?,
    technologies: firestoreStrings(data['technologies']),
    liveUrl: data['liveUrl'] as String?,
    githubUrl: data['githubUrl'] as String?,
  );
}

extension JobPositionModelFirestore on JobPositionModel {
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'category': category,
      'relatedSkills': relatedSkills,
      'searchCount': searchCount,
    };
  }
}

JobPositionModel jobPositionFromFirestore(String id, Map<String, dynamic> data) {
  return JobPositionModel(
    id: id,
    title: data['title'] as String? ?? '',
    category: data['category'] as String?,
    relatedSkills: firestoreStrings(data['relatedSkills']),
    searchCount: firestoreInt(data['searchCount']),
  );
}

List<T> _mapList<T>(dynamic value, T Function(Map<String, dynamic> data) parse) {
  if (value is! List) return const [];
  return value
      .map(firestoreMap)
      .whereType<Map<String, dynamic>>()
      .map(parse)
      .toList();
}
