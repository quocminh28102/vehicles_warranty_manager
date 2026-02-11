import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return const FirebaseOptions(
        apiKey: 'AIzaSyDWPV8nSr7CiocSxRrZKPdCLoFrGrror6s',
        authDomain: 'vehicles-warranty-manager.firebaseapp.com',
        projectId: 'vehicles-warranty-manager',
        storageBucket: 'vehicles-warranty-manager.firebasestorage.app',
        messagingSenderId: '559525380223',
        appId: '1:559525380223:web:446ae12ee8fd30c4437f4a',
        measurementId: 'G-Y33TT0ND7T',
      );
    }
    throw UnsupportedError(
      'FirebaseOptions are not configured for this platform.',
    );
  }
}
