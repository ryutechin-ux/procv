// CV Status constants used throughout the application
class CvStatus {
  CvStatus._();

  static const String draft = 'DRAFT';
  static const String pending = 'PENDING';
  static const String underReview = 'UNDER_REVIEW';
  static const String assigned = 'ASSIGNED';
  static const String inProgress = 'IN_PROGRESS';
  static const String submittedForReview = 'SUBMITTED_FOR_REVIEW';
  static const String revisionRequired = 'REVISION_REQUIRED';
  static const String approved = 'APPROVED';
  static const String rejected = 'REJECTED';
  static const String completed = 'COMPLETED';

  static const List<String> allStatuses = [
    draft,
    pending,
    underReview,
    assigned,
    inProgress,
    submittedForReview,
    revisionRequired,
    approved,
    rejected,
    completed,
  ];

  static String displayName(String status) {
    switch (status) {
      case draft:
        return 'Draft';
      case pending:
        return 'Pending';
      case underReview:
        return 'Under Review';
      case assigned:
        return 'Assigned';
      case inProgress:
        return 'In Progress';
      case submittedForReview:
        return 'Submitted for Review';
      case revisionRequired:
        return 'Revision Required';
      case approved:
        return 'Approved';
      case rejected:
        return 'Rejected';
      case completed:
        return 'Completed';
      default:
        return status;
    }
  }

  static bool isTerminal(String status) =>
      status == approved || status == rejected || status == completed;
}

// User roles
class UserRole {
  UserRole._();

  static const String user = 'user';
  static const String developer = 'developer';
  static const String admin = 'admin';
}

// Priority levels for work assignments
class Priority {
  Priority._();

  static const String low = 'LOW';
  static const String medium = 'MEDIUM';
  static const String high = 'HIGH';
  static const String urgent = 'URGENT';

  static const List<String> all = [low, medium, high, urgent];
}

// Notification types
class NotificationType {
  NotificationType._();

  static const String cvSubmitted = 'CV_SUBMITTED';
  static const String cvAssigned = 'CV_ASSIGNED';
  static const String cvInProgress = 'CV_IN_PROGRESS';
  static const String cvReadyForReview = 'CV_READY_FOR_REVIEW';
  static const String cvApproved = 'CV_APPROVED';
  static const String cvRevisionRequired = 'CV_REVISION_REQUIRED';
  static const String newWorkAssigned = 'NEW_WORK_ASSIGNED';
  static const String revisionRequested = 'REVISION_REQUESTED';
  static const String submissionApproved = 'SUBMISSION_APPROVED';
  static const String newCvRequest = 'NEW_CV_REQUEST';
  static const String developerSubmitted = 'DEVELOPER_SUBMITTED';
  static const String revisionCompleted = 'REVISION_COMPLETED';
}

