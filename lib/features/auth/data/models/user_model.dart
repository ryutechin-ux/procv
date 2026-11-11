/// User model
class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? photoURL;
  final String role;
  final String? phone;
  final String? location;
  final bool isBlocked;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoURL,
    this.role = 'user',
    this.phone,
    this.location,
    this.isBlocked = false,
    required this.createdAt,
    this.updatedAt,
  });

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    String? role,
    String? phone,
    String? location,
    bool? isBlocked,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      isBlocked: isBlocked ?? this.isBlocked,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'role': role,
      'phone': phone,
      'location': location,
      'isBlocked': isBlocked,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      photoURL: map['photoURL'],
      role: map['role'] ?? 'user',
      phone: map['phone'],
      location: map['location'],
      isBlocked: map['isBlocked'] ?? false,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt:
          map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }
}

