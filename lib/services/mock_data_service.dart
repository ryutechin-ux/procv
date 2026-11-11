import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/data/models/user_model.dart';
import '../features/developer_dashboard/data/models/work_assignment_model.dart';
import '../features/notifications/data/models/notification_model.dart';
import '../features/portfolio/data/models/portfolio_model.dart';
import '../features/position_search/data/models/job_position_model.dart';
import '../features/user_dashboard/data/models/cv_request_model.dart';
import '../firebase_bootstrap.dart';
import 'app_database.dart';
import 'firebase_repository.dart';
import 'job_catalog.dart';

export 'firebase_repository.dart';

/// In-memory mock data used for demo testing and fallback before Firebase configuration.
class MockDataService {
  static final List<UserModel> users = [
    UserModel(
      uid: 'user_admin',
      email: 'admin@procv.com',
      displayName: 'System Admin',
      role: 'admin',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    UserModel(
      uid: 'user_developer',
      email: 'dev@procv.com',
      displayName: 'Sarah Developer',
      role: 'developer',
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
    UserModel(
      uid: 'user_demo',
      email: 'john.doe@example.com',
      displayName: 'John Doe',
      role: 'user',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];

  static final List<CvRequestModel> cvRequests = [];
  static final List<WorkAssignmentModel> workAssignments = [];
  static final List<CvSubmissionModel> cvSubmissions = [];
  static final List<DeveloperModel> developers = [
    DeveloperModel(
      id: 'dev_01',
      userId: 'user_developer',
      name: 'Sarah Developer',
      email: 'dev@procv.com',
      isActive: true,
      assignedCount: 0,
      completedCount: 0,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
  ];
  static final List<NotificationModel> notifications = [];
  static final List<PortfolioModel> portfolios = [];
  static final List<JobPositionModel> jobPositions = List.from(jobCatalog);
}

final databaseProvider = StateNotifierProvider<AppDatabase, AppData>((ref) {
  final database = AppDatabase(firebaseConfigured ? FirebaseFirestore.instance : null);
  ref.listen<UserModel?>(currentUserProvider, (previous, next) {
    if (next == null || (firebaseConfigured && FirebaseAuth.instance.currentUser == null)) {
      database.stop();
    } else {
      database.start(seedCatalog: next.role == 'admin');
    }
  }, fireImmediately: true);
  return database;
});

final currentUserProvider = StateProvider<UserModel?>((ref) => null);

bool get isFirebaseLive => firebaseConfigured && FirebaseAuth.instance.currentUser != null;

final authBinderProvider = Provider<void>((ref) {
  if (!firebaseConfigured) return;
  final repository = ref.watch(firebaseRepositoryProvider);
  final subscription = FirebaseAuth.instance.authStateChanges().listen((firebaseUser) async {
    if (firebaseUser == null) {
      ref.read(currentUserProvider.notifier).state = null;
      return;
    }
    try {
      final profile = await repository.profileFor(firebaseUser);
      if (profile.isBlocked) {
        await repository.signOut();
        ref.read(currentUserProvider.notifier).state = null;
        return;
      }
      ref.read(currentUserProvider.notifier).state = profile;
    } catch (_) {
      ref.read(currentUserProvider.notifier).state = null;
    }
  });
  ref.onDispose(subscription.cancel);
});

final currentUserRoleProvider = Provider<String>((ref) {
  return ref.watch(currentUserProvider)?.role ?? 'user';
});

final allUsersProvider = Provider<List<UserModel>>((ref) {
  if (!isFirebaseLive) {
    return MockDataService.users.where((user) => user.role == 'user').toList();
  }
  final items = ref.watch(databaseProvider).users.where((user) => user.role == 'user').toList();
  return items.isNotEmpty ? items : MockDataService.users.where((user) => user.role == 'user').toList();
});

final userCvRequestsProvider = Provider<List<CvRequestModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const [];
  if (!isFirebaseLive) {
    return MockDataService.cvRequests.where((cv) => cv.userId == user.uid).toList();
  }
  final firestoreItems = ref.watch(databaseProvider).cvRequests.where((cv) => cv.userId == user.uid).toList();
  if (firestoreItems.isNotEmpty) return firestoreItems;
  return MockDataService.cvRequests.where((cv) => cv.userId == user.uid).toList();
});

final allCvRequestsProvider = Provider<List<CvRequestModel>>((ref) {
  if (!isFirebaseLive) {
    return MockDataService.cvRequests;
  }
  final firestoreItems = ref.watch(databaseProvider).cvRequests;
  if (firestoreItems.isNotEmpty) return firestoreItems;
  return MockDataService.cvRequests;
});

final developerAssignmentsProvider = Provider<List<WorkAssignmentModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const [];
  final email = user.email.toLowerCase();
  final list = isFirebaseLive
      ? ref.watch(databaseProvider).workAssignments
      : MockDataService.workAssignments;
  final results = list.where((assignment) {
    return assignment.developerId == user.uid || assignment.developerId == email;
  }).toList();
  if (results.isNotEmpty) return results;
  return MockDataService.workAssignments.where((assignment) {
    return assignment.developerId == user.uid || assignment.developerId == email;
  }).toList();
});

final allWorkAssignmentsProvider = Provider<List<WorkAssignmentModel>>((ref) {
  if (!isFirebaseLive) {
    return MockDataService.workAssignments;
  }
  final items = ref.watch(databaseProvider).workAssignments;
  return items.isNotEmpty ? items : MockDataService.workAssignments;
});

final cvSubmissionsProvider = Provider<List<CvSubmissionModel>>((ref) {
  if (!isFirebaseLive) {
    return MockDataService.cvSubmissions;
  }
  final items = ref.watch(databaseProvider).cvSubmissions;
  return items.isNotEmpty ? items : MockDataService.cvSubmissions;
});

final developersProvider = Provider<List<DeveloperModel>>((ref) {
  if (!isFirebaseLive) {
    return MockDataService.developers;
  }
  final items = ref.watch(databaseProvider).developers;
  return items.isNotEmpty ? items : MockDataService.developers;
});

final userNotificationsProvider = Provider<List<NotificationModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const [];
  final email = user.email.toLowerCase();
  final list = isFirebaseLive
      ? ref.watch(databaseProvider).notifications
      : MockDataService.notifications;
  final results = list.where((note) {
    return note.userId == user.uid || note.userId == email;
  }).toList();
  if (results.isNotEmpty) return results;
  return MockDataService.notifications.where((note) {
    return note.userId == user.uid || note.userId == email;
  }).toList();
});

final unreadNotificationCountProvider = Provider<int>((ref) {
  return ref.watch(userNotificationsProvider).where((note) => !note.isRead).length;
});

final jobPositionsProvider = Provider<List<JobPositionModel>>((ref) {
  if (!isFirebaseLive) {
    return MockDataService.jobPositions;
  }
  final items = ref.watch(databaseProvider).jobPositions;
  return items.isNotEmpty ? items : MockDataService.jobPositions;
});

final userPortfoliosProvider = Provider<List<PortfolioModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const [];
  final list = isFirebaseLive
      ? ref.watch(databaseProvider).portfolios
      : MockDataService.portfolios;
  final results = list.where((portfolio) => portfolio.userId == user.uid).toList();
  if (results.isNotEmpty) return results;
  return MockDataService.portfolios.where((portfolio) => portfolio.userId == user.uid).toList();
});
