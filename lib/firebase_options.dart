import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyCtNNTaYDuEe3iuYBsEPuzQ9IdH3_Yju9g',
    appId: '1:106903624928:web:aa37930e3731e21171c485',
    messagingSenderId: '106903624928',
    projectId: 'aplicacion-receta',
    authDomain: 'aplicacion-receta.firebaseapp.com',
    storageBucket: 'aplicacion-receta.firebasestorage.app',
    measurementId: 'G-8T3ZG7WJLY',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDG2t7NNLThMLroHSz3xjWC-CoGH2dMXk4',
    appId: '1:106903624928:android:40c0c1e7f9c3326571c485',
    messagingSenderId: '106903624928',
    projectId: 'aplicacion-receta',
    storageBucket: 'aplicacion-receta.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBW8KMe0Cv5N7-Sj42jVppFPfqzguHcdcM',
    appId: '1:106903624928:ios:6b8a2c7c171b094d71c485',
    messagingSenderId: '106903624928',
    projectId: 'aplicacion-receta',
    storageBucket: 'aplicacion-receta.firebasestorage.app',
    iosBundleId: 'com.example.aplicacionRecetas',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBW8KMe0Cv5N7-Sj42jVppFPfqzguHcdcM',
    appId: '1:106903624928:ios:6b8a2c7c171b094d71c485',
    messagingSenderId: '106903624928',
    projectId: 'aplicacion-receta',
    storageBucket: 'aplicacion-receta.firebasestorage.app',
    iosBundleId: 'com.example.aplicacionRecetas',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCtNNTaYDuEe3iuYBsEPuzQ9IdH3_Yju9g',
    appId: '1:106903624928:web:f374123661da1d0d71c485',
    messagingSenderId: '106903624928',
    projectId: 'aplicacion-receta',
    authDomain: 'aplicacion-receta.firebaseapp.com',
    storageBucket: 'aplicacion-receta.firebasestorage.app',
    measurementId: 'G-EVX03MZSF4',
  );
}
