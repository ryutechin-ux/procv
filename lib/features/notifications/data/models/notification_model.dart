/// Notification model for in-app notifications
class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type;
  final String? relatedRequestId;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.relatedRequestId,
    this.isRead = false,
    required this.createdAt,
  });

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      userId: userId,
      title: title,
      message: message,
      type: type,
      relatedRequestId: relatedRequestId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }
}

