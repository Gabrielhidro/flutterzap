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
    apiKey: 'AIzaSyBXpu885mDL3W0cNJ04WYdTvGjWO4WyMfo',
    appId: '1:942362588293:web:3c36c4497f4e1df700e5ec',
    messagingSenderId: '942362588293',
    projectId: 'flutterzap-1b886',
    authDomain: 'flutterzap-1b886.firebaseapp.com',
    databaseURL: 'https://flutterzap-1b886-default-rtdb.firebaseio.com',
    storageBucket: 'flutterzap-1b886.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDaKjBAMdIyBRkYsYAJ4Z76362CVbtkvAc',
    appId: '1:942362588293:android:68a4ef669951b69400e5ec',
    messagingSenderId: '942362588293',
    projectId: 'flutterzap-1b886',
    databaseURL: 'https://flutterzap-1b886-default-rtdb.firebaseio.com',
    storageBucket: 'flutterzap-1b886.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBdXqMvR3tR4QIG-kSWPh6sRD4EnjHswdE',
    appId: '1:942362588293:ios:bdbe09adebe30af900e5ec',
    messagingSenderId: '942362588293',
    projectId: 'flutterzap-1b886',
    databaseURL: 'https://flutterzap-1b886-default-rtdb.firebaseio.com',
    storageBucket: 'flutterzap-1b886.appspot.com',
    iosClientId: '942362588293-4lnbgi1344j59rmetc473dabb19di788.apps.googleusercontent.com',
    iosBundleId: 'com.example.flutterApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBdXqMvR3tR4QIG-kSWPh6sRD4EnjHswdE',
    appId: '1:942362588293:ios:b5b2a8774b7aa1c000e5ec',
    messagingSenderId: '942362588293',
    projectId: 'flutterzap-1b886',
    databaseURL: 'https://flutterzap-1b886-default-rtdb.firebaseio.com',
    storageBucket: 'flutterzap-1b886.appspot.com',
    iosClientId: '942362588293-2n0qe5hplo4qnihimk0rn460birk789n.apps.googleusercontent.com',
    iosBundleId: 'com.example.flutterApp.RunnerTests',
  );
}
