// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyChp1O43LlHWkSJai19IfgNrB-hiFl62mk',
    appId: '1:1069922306513:web:a174d65087ad9e738df8f0',
    messagingSenderId: '1069922306513',
    projectId: 'chatwith-fcb71',
    authDomain: 'chatwith-fcb71.firebaseapp.com',
    storageBucket: 'chatwith-fcb71.appspot.com',
    measurementId: 'G-K5B0X9KMSV',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDCAvqIgNh7F7uWP8-KI6FmLRbYkRgkSzc',
    appId: '1:1069922306513:android:028ec85619d5a1c28df8f0',
    messagingSenderId: '1069922306513',
    projectId: 'chatwith-fcb71',
    storageBucket: 'chatwith-fcb71.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCl9GJIgpZKsVBv-0ArDXl3ZOEPObjuc0g',
    appId: '1:1069922306513:ios:db2bdf9cac8d1dc58df8f0',
    messagingSenderId: '1069922306513',
    projectId: 'chatwith-fcb71',
    storageBucket: 'chatwith-fcb71.appspot.com',
    iosBundleId: 'com.example.chatwith',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCl9GJIgpZKsVBv-0ArDXl3ZOEPObjuc0g',
    appId: '1:1069922306513:ios:7aed3edcf0eb04768df8f0',
    messagingSenderId: '1069922306513',
    projectId: 'chatwith-fcb71',
    storageBucket: 'chatwith-fcb71.appspot.com',
    iosBundleId: 'com.example.chatwith.RunnerTests',
  );
}
