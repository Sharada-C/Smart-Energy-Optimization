import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _databaseURL = "https://smartenergyoptimization-default-rtdb.asia-southeast1.firebasedatabase.app";
  
  late final DatabaseReference _dbRef;

  FirebaseService() {
    // Initializing the specific Singapore region database
    _dbRef = FirebaseDatabase.instanceFor(
      app: FirebaseDatabase.instance.app, 
      databaseURL: _databaseURL
    ).ref();
  }

  // --- Auth Logic ---
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<bool> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      debugPrint("Login Error: $e");
      return false;
    }
  }

  Future<void> logout() async => await _auth.signOut();

  // --- Database Logic ---
  Stream<DatabaseEvent> get dataStream => _dbRef.onValue;

  /// Updates the device state (Relays) in Firebase
  Future<void> toggleDevice(String deviceName, bool newValue) async {
    String firebasePath;

    // Mapping UI names to the exact Arduino path names (No Spaces!)
    if (deviceName == "Living Room Lights") {
      firebasePath = "LivingRoomLights";
    } else if (deviceName == "Fan") {
      firebasePath = "FanState";
    } else {
      // Handles 'testLoad' or any other specific names
      firebasePath = deviceName; 
    }

    try {
      // Using _dbRef ensures we write to the correct URL
      await _dbRef.child(firebasePath).set(newValue);
      debugPrint("Firebase Write Success: $firebasePath -> $newValue");
    } catch (e) {
      debugPrint("Error updating device: $e");
    }
  }

  /// Toggles the AI Optimization mode
  Future<void> toggleSmartMode(bool isSmart) async {
    try {
      await _dbRef.child('isSmartMode').set(isSmart);
      debugPrint("Smart Mode Toggled: $isSmart");
    } catch (e) {
      debugPrint("Error updating Smart Mode: $e");
    }
  }
}