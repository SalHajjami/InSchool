// File generated by FlutterFire CLI.
// ignore_for_file: type=lint

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
        return windows;
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
    apiKey: 'AIzaSyBVyq8WyS-XZ019J3XmIgm-2uXm3tPOb5E',
    appId: '1:851753845171:web:14096a77baff7776ee0bc6',
    messagingSenderId: '851753845171',
    projectId: 'authenticate-e6991',
    authDomain: 'authenticate-e6991.firebaseapp.com',
    storageBucket: 'authenticate-e6991.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBsS9WMGPYt4rCrol8pMmo2w0SzLG1jMFU',
    appId: '1:851753845171:android:0a80fffddb1d7c10ee0bc6',
    messagingSenderId: '851753845171',
    projectId: 'authenticate-e6991',
    storageBucket: 'authenticate-e6991.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBFaUjvwCPIfppcDO963AohG7cXADGvd1o',
    appId: '1:851753845171:ios:23ec7a437d9953e0ee0bc6',
    messagingSenderId: '851753845171',
    projectId: 'authenticate-e6991',
    storageBucket: 'authenticate-e6991.appspot.com',
    iosBundleId: 'com.example.inschool',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBFaUjvwCPIfppcDO963AohG7cXADGvd1o',
    appId: '1:851753845171:ios:23ec7a437d9953e0ee0bc6',
    messagingSenderId: '851753845171',
    projectId: 'authenticate-e6991',
    storageBucket: 'authenticate-e6991.appspot.com',
    iosBundleId: 'com.example.inschool',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBVyq8WyS-XZ019J3XmIgm-2uXm3tPOb5E',
    appId: '1:851753845171:web:64ee4d4701de18adee0bc6',
    messagingSenderId: '851753845171',
    projectId: 'authenticate-e6991',
    authDomain: 'authenticate-e6991.firebaseapp.com',
    storageBucket: 'authenticate-e6991.appspot.com',
  );

}
