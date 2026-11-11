import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'firebase_bootstrap.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (DefaultFirebaseOptions.web.apiKey != firebasePlaceholderApiKey) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      firebaseConfigured = true;
    } catch (e) {
      debugPrint('Firebase initialization failed: $e');
    }
  }

  runApp(const ProviderScope(child: ProCvApp()));
}
