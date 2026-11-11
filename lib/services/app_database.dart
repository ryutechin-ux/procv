import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/data/models/user_model.dart';
import '../features/developer_dashboard/data/models/work_assignment_model.dart';
import '../features/notifications/data/models/notification_model.dart';
import '../features/portfolio/data/models/portfolio_model.dart';
import '../features/position_search/data/models/job_position_model.dart';
import '../features/user_dashboard/data/models/cv_request_model.dart';
import 'firestore_paths.dart';
import 'job_catalog.dart';
import 'model_maps.dart';

class AppData {
  final List<UserModel> users;
  final List<CvRequestModel> cvRequests;
  final List<WorkAssignmentModel> workAssignments;
  final List<CvSubmissionModel> cvSubmissions;
  final List<DeveloperModel> developers;
  final List<NotificationModel> notifications;
  final List<PortfolioModel> portfolios;
  final List<JobPositionModel> jobPositions;

  const AppData({
    this.users = const [],
    this.cvRequests = const [],
    this.workAssignments = const [],
    this.cvSubmissions = const [],
    this.developers = const [],
    this.notifications = const [],
    this.portfolios = const [],
    this.jobPositions = const [],
  });

  AppData copyWith({
    List<UserModel>? users,
    List<CvRequestModel>? cvRequests,
    List<WorkAssignmentModel>? workAssignments,
    List<CvSubmissionModel>? cvSubmissions,
    List<DeveloperModel>? developers,
    List<NotificationModel>? notifications,
    List<PortfolioModel>? portfolios,
    List<JobPositionModel>? jobPositions,
  }) {
    return AppData(
      users: users ?? this.users,
      cvRequests: cvRequests ?? this.cvRequests,
      workAssignments: workAssignments ?? this.workAssignments,
      cvSubmissions: cvSubmissions ?? this.cvSubmissions,
      developers: developers ?? this.developers,
      notifications: notifications ?? this.notifications,
      portfolios: portfolios ?? this.portfolios,
      jobPositions: jobPositions ?? this.jobPositions,
    );
  }
}

class AppDatabase extends StateNotifier<AppData> {
  AppDatabase([this._firestore]) : super(const AppData());

  final FirebaseFirestore? _firestore;
  final List<StreamSubscription<QuerySnapshot<Map<String, dynamic>>>> _subs = [];
  bool _started = false;

  void start({required bool seedCatalog}) {
    final firestore = _firestore;
    if (firestore == null || _started) return;
    _started = true;
    _listen(FirestorePaths.users, (docs) {
      final users = _map(docs, userFromFirestore)..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      state = state.copyWith(users: users);
    });
    _listen(FirestorePaths.cvRequests, (docs) {
      final items = _map(docs, cvRequestFromFirestore)..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      state = state.copyWith(cvRequests: items);
    });
    _listen(FirestorePaths.workAssignments, (docs) {
      final items = _map(docs, workAssignmentFromFirestore)..sort((a, b) => b.assignedAt.compareTo(a.assignedAt));
      state = state.copyWith(workAssignments: items);
    });
    _listen(FirestorePaths.cvSubmissions, (docs) {
      final items = _map(docs, cvSubmissionFromFirestore)..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
      state = state.copyWith(cvSubmissions: items);
    });
    _listen(FirestorePaths.developers, (docs) {
      final items = _map(docs, developerFromFirestore)..sort((a, b) => a.name.compareTo(b.name));
      state = state.copyWith(developers: items);
    });
    _listen(FirestorePaths.notifications, (docs) {
      final items = _map(docs, notificationFromFirestore)..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      state = state.copyWith(notifications: items);
    });
    _listen(FirestorePaths.portfolios, (docs) {
      final items = _map(docs, portfolioFromFirestore)..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      state = state.copyWith(portfolios: items);
    });
    _listen(FirestorePaths.jobPositions, (docs) {
      final items = _map(docs, jobPositionFromFirestore)..sort((a, b) => b.searchCount.compareTo(a.searchCount));
      state = state.copyWith(jobPositions: items);
    });
    if (seedCatalog) {
      unawaited(_seedJobCatalog());
    }
  }

  void stop() {
    if (!_started && _subs.isEmpty) return;
    for (final sub in _subs) {
      sub.cancel();
    }
    _subs.clear();
    _started = false;
    state = const AppData();
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }

  void _listen(
    String collection,
    void Function(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) apply,
  ) {
    final firestore = _firestore;
    if (firestore == null) return;
    final sub = firestore.collection(collection).snapshots().listen(
      (snap) => apply(snap.docs),
      onError: (Object _) {},
    );
    _subs.add(sub);
  }

  Future<void> _seedJobCatalog() async {
    final firestore = _firestore;
    if (firestore == null) return;
    try {
      final existing = await firestore.collection(FirestorePaths.jobPositions).limit(1).get();
      if (existing.docs.isNotEmpty) return;
      final batch = firestore.batch();
      for (final position in jobCatalog) {
        batch.set(
          firestore.collection(FirestorePaths.jobPositions).doc(position.id),
          position.toFirestore(),
        );
      }
      await batch.commit();
    } catch (_) {}
  }
}

List<T> _map<T>(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  T Function(String id, Map<String, dynamic> data) parse,
) {
  final items = <T>[];
  for (final doc in docs) {
    try {
      items.add(parse(doc.id, doc.data()));
    } catch (_) {}
  }
  return items;
}
