import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase config for ProCV.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        throw UnsupportedError(
          'Android is not configured. Run flutterfire configure.',
        );
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'iOS is not configured. Run flutterfire configure.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'macOS is not configured. Run flutterfire configure.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'Windows is not configured. Run flutterfire configure.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'Linux is not configured. Run flutterfire configure.',
        );
      default:
        throw UnsupportedError('This platform is not configured for Firebase.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA8-4vQtsDOriRsBbW9L4Vp7KDz4ASqnLs',
    appId: '1:205790390568:web:2e44b5cb0307a00c90c81d',
    messagingSenderId: '205790390568',
    projectId: 'cvbuilder-ea3ab',
    authDomain: 'cvbuilder-ea3ab.firebaseapp.com',
    storageBucket: 'cvbuilder-ea3ab.firebasestorage.app',
    measurementId: 'G-M49MYGVWB4',
  );
}
