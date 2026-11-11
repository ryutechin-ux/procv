/// Work assignment model - tracks admin-to-developer assignments
class WorkAssignmentModel {
  final String id;
  final String cvRequestId;
  final String developerId;
  final String developerName;
  final String adminId;
  final String priority;
  final String? instructions;
  final String status;
  final String userName;
  final String cvPosition;
  final DateTime assignedAt;
  final DateTime? updatedAt;

  const WorkAssignmentModel({
    required this.id,
    required this.cvRequestId,
    required this.developerId,
    required this.developerName,
    required this.adminId,
    required this.priority,
    this.instructions,
    this.status = 'ASSIGNED',
    required this.userName,
    required this.cvPosition,
    required this.assignedAt,
    this.updatedAt,
  });
}

/// CV submission model - tracks developer's submitted CV work
class CvSubmissionModel {
  final String id;
  final String cvRequestId;
  final String developerId;
  final String? watermarkedPdfUrl;
  final String? originalPdfUrl;
  final String? notes;
  final String status;
  final DateTime submittedAt;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final String? revisionReason;

  const CvSubmissionModel({
    required this.id,
    required this.cvRequestId,
    required this.developerId,
    this.watermarkedPdfUrl,
    this.originalPdfUrl,
    this.notes,
    this.status = 'SUBMITTED_FOR_REVIEW',
    required this.submittedAt,
    this.reviewedBy,
    this.reviewedAt,
    this.revisionReason,
  });
}

/// Developer profile model
class DeveloperModel {
  final String id;
  final String userId;
  final String name;
  final String email;
  final bool isActive;
  final int assignedCount;
  final int completedCount;
  final DateTime createdAt;

  const DeveloperModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    this.isActive = true,
    this.assignedCount = 0,
    this.completedCount = 0,
    required this.createdAt,
  });
}

