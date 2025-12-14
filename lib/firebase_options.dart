// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart';

class FirebaseOptions {
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyBwQLzlY8lNZ1HoRImlpX7h3QM5NdedwM0",
    authDomain: "elura-e49ee.firebaseapp.com",
    databaseURL: "https://elura-e49ee-default-rtdb.asia-southeast1.firebasedatabase.app",
    projectId: "elura-e49ee",
    storageBucket: "elura-e49ee.firebasestorage.app",
    messagingSenderId: "499664339630",
    appId: "1:499664339630:web:47cddd967f2438ddaf633f",
    measurementId: "G-F8ENHTHXFF",
  );

  final String apiKey;
  final String appId;
  final String messagingSenderId;
  final String projectId;
  final String authDomain;
  final String databaseURL; // ← MAKE SURE THIS IS HERE
  final String storageBucket;
  final String? measurementId;

  const FirebaseOptions({
    required this.apiKey,
    required this.appId,
    required this.messagingSenderId,
    required this.projectId,
    required this.authDomain,
    required this.databaseURL, // ← REQUIRED
    required this.storageBucket,
    this.measurementId,
  });
}