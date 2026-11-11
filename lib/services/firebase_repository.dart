import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/data/models/user_model.dart';
import '../features/developer_dashboard/data/models/work_assignment_model.dart';
import '../features/notifications/data/models/notification_model.dart';
import '../features/portfolio/data/models/portfolio_model.dart';
import '../features/user_dashboard/data/models/cv_request_model.dart';
import '../firebase_bootstrap.dart';
import 'firestore_paths.dart';
import 'model_maps.dart';

final firebaseRepositoryProvider = Provider<FirebaseRepository>((ref) {
  if (!firebaseConfigured) {
    throw StateError('Firebase is not yet configured. Please configure your Firebase credentials.');
  }
  return FirebaseRepository(FirebaseAuth.instance, FirebaseFirestore.instance);
});

class FirebaseRepository {
  FirebaseRepository(this._auth, this._db);

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return _profileAfterSignIn(credential.user!);
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await credential.user?.updateDisplayName(name.trim());
    return _profileAfterSignIn(credential.user!, displayName: name.trim());
  }

  Future<UserModel> signInWithGoogle() async {
    final credential = await _auth.signInWithPopup(GoogleAuthProvider());
    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'popup-closed-by-user',
        message: 'Google sign-in was cancelled.',
      );
    }
    return _profileAfterSignIn(user);
  }

  Future<void> sendPasswordReset(String email) {
    return _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> signOut() => _auth.signOut();

  Future<UserModel> profileFor(User firebaseUser, {String? displayName}) async {
    final userRef = _db.collection(FirestorePaths.users).doc(firebaseUser.uid);
    final email = (firebaseUser.email ?? '').trim();
    final emailKey = email.toLowerCase();
    final name = (displayName ?? firebaseUser.displayName ?? emailKey.split('@').first).trim();

    final profile = await _db.runTransaction<UserModel>((tx) async {
      final userSnap = await tx.get(userRef);
      if (userSnap.exists) {
        return userFromFirestore(userSnap.id, userSnap.data()!);
      }

      final devRef = _db.collection(FirestorePaths.developers).doc(emailKey);
      final devSnap = await tx.get(devRef);
      final bootstrapRef = _db.collection(FirestorePaths.meta).doc(FirestorePaths.bootstrap);
      final bootSnap = await tx.get(bootstrapRef);

      var role = 'user';
      if (devSnap.exists) role = 'developer';
      final isAdminCandidate = emailKey.contains('admin') ||
          (!bootSnap.exists && emailKey.contains('admin')) ||
          (bootSnap.exists && bootSnap.data()?['adminUid'] == firebaseUser.uid);
      if (isAdminCandidate) {
        role = 'admin';
        if (!bootSnap.exists) {
          tx.set(bootstrapRef, {
            'adminUid': firebaseUser.uid,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }

      final created = UserModel(
        uid: firebaseUser.uid,
        email: email,
        displayName: name.isEmpty ? 'ProCV User' : name,
        photoURL: firebaseUser.photoURL,
        role: role,
        createdAt: DateTime.now(),
      );
      tx.set(userRef, created.toFirestore());
      if (devSnap.exists) {
        tx.update(devRef, {'userId': firebaseUser.uid});
      }
      return created;
    });

    await _claimDeveloperWork(emailKey, firebaseUser.uid);
    return profile;
  }

  Future<void> saveCv(CvRequestModel cv) {
    return _db.collection(FirestorePaths.cvRequests).doc(cv.id).set(cv.toFirestore());
  }

  Future<void> savePortfolio(PortfolioModel portfolio) {
    return _db.collection(FirestorePaths.portfolios).doc(portfolio.id).set(portfolio.toFirestore());
  }

  Future<void> deletePortfolio(String id) {
    return _db.collection(FirestorePaths.portfolios).doc(id).delete();
  }

  Future<void> setUserBlocked(String uid, bool isBlocked) {
    return _db.collection(FirestorePaths.users).doc(uid).update({
      'isBlocked': isBlocked,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> saveDeveloper({required String name, required String email}) async {
    final normalized = email.trim().toLowerCase();
    final existingUsers = await _db
        .collection(FirestorePaths.users)
        .where('email', isEqualTo: normalized)
        .limit(1)
        .get();
    final userId = existingUsers.docs.isEmpty ? normalized : existingUsers.docs.first.id;
    if (existingUsers.docs.isNotEmpty) {
      await existingUsers.docs.first.reference.update({'role': 'developer'});
    }
    final developer = DeveloperModel(
      id: normalized,
      userId: userId,
      name: name.trim(),
      email: normalized,
      createdAt: DateTime.now(),
    );
    await _db.collection(FirestorePaths.developers).doc(normalized).set(developer.toFirestore());
  }

  Future<void> setDeveloperActive(DeveloperModel developer, bool isActive) {
    return _db.collection(FirestorePaths.developers).doc(developer.id).update({
      'isActive': isActive,
    });
  }

  Future<void> markNotificationRead(String id) {
    return _db.collection(FirestorePaths.notifications).doc(id).update({'isRead': true});
  }

  Future<void> markAllRead(String userId) async {
    final snap = await _db
        .collection(FirestorePaths.notifications)
        .where('userId', isEqualTo: userId)
        .get();
    final unread = snap.docs.where((doc) => doc.data()['isRead'] != true);
    final batch = _db.batch();
    for (final doc in unread) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Future<void> assignWork({
    required CvRequestModel cv,
    required DeveloperModel developer,
    required String adminId,
    required String priority,
    required String instructions,
  }) async {
    final assignmentRef = _db.collection(FirestorePaths.workAssignments).doc();
    final devNoteRef = _db.collection(FirestorePaths.notifications).doc();
    final userNoteRef = _db.collection(FirestorePaths.notifications).doc();
    final now = DateTime.now();
    final developerKey = developer.userId.isEmpty ? developer.email : developer.userId;

    final assignment = WorkAssignmentModel(
      id: assignmentRef.id,
      cvRequestId: cv.id,
      developerId: developerKey,
      developerName: developer.name,
      adminId: adminId,
      priority: priority,
      instructions: instructions,
      status: 'ASSIGNED',
      userName: cv.personalInfo?.fullName ?? 'Candidate',
      cvPosition: cv.position,
      assignedAt: now,
    );
    final developerNote = NotificationModel(
      id: devNoteRef.id,
      userId: developerKey,
      title: 'New Work Assigned ($priority Priority)',
      message: 'You have been assigned to prepare the CV for "${cv.position}".',
      type: 'NEW_WORK_ASSIGNED',
      relatedRequestId: cv.id,
      createdAt: now,
    );
    final userNote = NotificationModel(
      id: userNoteRef.id,
      userId: cv.userId,
      title: 'CV Work Assigned',
      message:
          'Great news! Your CV request for "${cv.position}" has been assigned to expert developer ${developer.name}.',
      type: 'CV_ASSIGNED',
      relatedRequestId: cv.id,
      createdAt: now,
    );

    final batch = _db.batch();
    batch.set(assignmentRef, assignment.toFirestore());
    batch.update(_db.collection(FirestorePaths.cvRequests).doc(cv.id), {
      'status': 'ASSIGNED',
      'updatedAt': Timestamp.fromDate(now),
    });
    batch.set(devNoteRef, developerNote.toFirestore());
    batch.set(userNoteRef, userNote.toFirestore());
    batch.update(_db.collection(FirestorePaths.developers).doc(developer.id), {
      'assignedCount': FieldValue.increment(1),
    });
    await batch.commit();
  }

  Future<void> submitWork({
    required WorkAssignmentModel assignment,
    required String notes,
    required String watermarkedPdfUrl,
    required String originalPdfUrl,
  }) async {
    final submissionRef = _db.collection(FirestorePaths.cvSubmissions).doc();
    final now = DateTime.now();
    final submission = CvSubmissionModel(
      id: submissionRef.id,
      cvRequestId: assignment.cvRequestId,
      developerId: _auth.currentUser?.uid ?? assignment.developerId,
      watermarkedPdfUrl: watermarkedPdfUrl,
      originalPdfUrl: originalPdfUrl,
      notes: notes,
      status: 'SUBMITTED_FOR_REVIEW',
      submittedAt: now,
    );
    final batch = _db.batch();
    batch.set(submissionRef, submission.toFirestore());
    batch.update(_db.collection(FirestorePaths.workAssignments).doc(assignment.id), {
      'status': 'SUBMITTED_FOR_REVIEW',
      'updatedAt': Timestamp.fromDate(now),
    });
    batch.update(_db.collection(FirestorePaths.cvRequests).doc(assignment.cvRequestId), {
      'status': 'SUBMITTED_FOR_REVIEW',
      'updatedAt': Timestamp.fromDate(now),
    });
    await batch.commit();
  }

  Future<void> approveSubmission(CvSubmissionModel submission, {required String adminId}) async {
    final cvRef = _db.collection(FirestorePaths.cvRequests).doc(submission.cvRequestId);
    final cvSnap = await cvRef.get();
    final cv = cvSnap.exists ? cvRequestFromFirestore(cvSnap.id, cvSnap.data()!) : null;
    final assignments = await _db
        .collection(FirestorePaths.workAssignments)
        .where('cvRequestId', isEqualTo: submission.cvRequestId)
        .limit(1)
        .get();
    final now = DateTime.now();
    final batch = _db.batch();
    batch.update(cvRef, {
      'status': 'APPROVED',
      'updatedAt': Timestamp.fromDate(now),
    });
    batch.update(_db.collection(FirestorePaths.cvSubmissions).doc(submission.id), {
      'status': 'APPROVED',
      'reviewedBy': adminId,
      'reviewedAt': Timestamp.fromDate(now),
    });
    if (assignments.docs.isNotEmpty) {
      final assignment = assignments.docs.first;
      batch.update(assignment.reference, {
        'status': 'COMPLETED',
        'updatedAt': Timestamp.fromDate(now),
      });
      final developerId = assignment.data()['developerId'] as String?;
      if (developerId != null && developerId.isNotEmpty) {
        final devs = await _db
            .collection(FirestorePaths.developers)
            .where('userId', isEqualTo: developerId)
            .limit(1)
            .get();
        if (devs.docs.isNotEmpty) {
          batch.update(devs.docs.first.reference, {
            'completedCount': FieldValue.increment(1),
          });
        }
      }
    }
    if (cv != null) {
      final noteRef = _db.collection(FirestorePaths.notifications).doc();
      batch.set(
        noteRef,
        NotificationModel(
          id: noteRef.id,
          userId: cv.userId,
          title: 'Your Professional CV is Approved!',
          message:
              'Your CV for "${cv.position}" has passed our quality check. The final watermark-free PDF is now unlocked for download.',
          type: 'CV_APPROVED',
          relatedRequestId: cv.id,
          createdAt: now,
        ).toFirestore(),
      );
    }
    await batch.commit();
  }

  Future<void> requestRevision(CvSubmissionModel submission, {required String reason}) async {
    final assignments = await _db
        .collection(FirestorePaths.workAssignments)
        .where('cvRequestId', isEqualTo: submission.cvRequestId)
        .limit(1)
        .get();
    final now = DateTime.now();
    final batch = _db.batch();
    batch.update(_db.collection(FirestorePaths.cvRequests).doc(submission.cvRequestId), {
      'status': 'REVISION_REQUIRED',
      'updatedAt': Timestamp.fromDate(now),
    });
    batch.update(_db.collection(FirestorePaths.cvSubmissions).doc(submission.id), {
      'status': 'REVISION_REQUIRED',
      'revisionReason': reason,
      'reviewedAt': Timestamp.fromDate(now),
    });
    if (assignments.docs.isNotEmpty) {
      final data = assignments.docs.first.data();
      batch.update(assignments.docs.first.reference, {
        'status': 'REVISION_REQUIRED',
        'priority': 'URGENT',
        'instructions': 'REVISION: $reason',
        'updatedAt': Timestamp.fromDate(now),
      });
      final noteRef = _db.collection(FirestorePaths.notifications).doc();
      batch.set(
        noteRef,
        NotificationModel(
          id: noteRef.id,
          userId: data['developerId'] as String? ?? '',
          title: 'Revision Requested for ${data['userName'] ?? 'a candidate'}',
          message: 'Admin has requested revisions: "$reason"',
          type: 'REVISION_REQUESTED',
          relatedRequestId: submission.cvRequestId,
          createdAt: now,
        ).toFirestore(),
      );
    }
    await batch.commit();
  }

  Future<UserModel> _profileAfterSignIn(User firebaseUser, {String? displayName}) async {
    final profile = await profileFor(firebaseUser, displayName: displayName);
    if (profile.isBlocked) {
      await signOut();
      throw FirebaseAuthException(
        code: 'user-disabled',
        message: 'This account has been blocked. Contact an administrator.',
      );
    }
    return profile;
  }

  Future<void> _claimDeveloperWork(String email, String uid) async {
    if (email.isEmpty || email == uid) return;
    final assignments = await _db
        .collection(FirestorePaths.workAssignments)
        .where('developerId', isEqualTo: email)
        .get();
    final notes = await _db
        .collection(FirestorePaths.notifications)
        .where('userId', isEqualTo: email)
        .get();
    if (assignments.docs.isEmpty && notes.docs.isEmpty) return;
    final batch = _db.batch();
    for (final doc in assignments.docs) {
      batch.update(doc.reference, {'developerId': uid});
    }
    for (final doc in notes.docs) {
      batch.update(doc.reference, {'userId': uid});
    }
    await batch.commit();
  }
}

String firebaseErrorMessage(Object error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
      case 'invalid-email':
        return 'Email or password is incorrect.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'weak-password':
        return 'Use a password of at least 6 characters.';
      case 'too-many-requests':
        return 'Too many attempts. Try again in a few minutes.';
      case 'user-disabled':
        return error.message ?? 'This account has been blocked.';
      case 'popup-closed-by-user':
      case 'cancelled-popup-request':
        return 'Google sign-in was cancelled.';
      default:
        return error.message ?? 'Authentication failed.';
    }
  }
  if (error is FirebaseException) {
    if (error.code == 'permission-denied') {
      return 'Firestore rejected this change. Deploy the security rules, then try again.';
    }
    return error.message ?? 'Firebase request failed.';
  }
  return 'Something went wrong. Please try again.';
}
