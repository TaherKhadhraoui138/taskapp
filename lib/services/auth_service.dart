import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../models/user.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;

  // Register user
  Future<User?> register(String email, String password, String name) async {
    try {
      final fb_auth.UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final newUser = User(
        id: userCredential.user!.uid,
        email: email,
        name: name,
          passwordHash: myCustomHash(password)
      );

      await _firestore.collection('users').doc(newUser.id).set(newUser.toJson());
      return newUser;
    } on fb_auth.FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        print('Erreur: Cet email existe déjà !');
      } else {
        print('Erreur FirebaseAuth: ${e.code}');
      }
      return null;
    } catch (e) {
      print('Erreur inconnue: $e');
      return null;
    }
  }

  // Login user
  Future<User?> login(String email, String password) async {
    try {
      final fb_auth.UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final doc = await _firestore.collection('users').doc(userCredential.user!.uid).get();

      if (doc.exists) {
        return User.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  // Get current user (attend que Firebase Auth ait restauré l'état)
  Future<User?> getCurrentUser() async {
    // Wait for Firebase Auth to fully initialize and restore auth state
    // Using a completer to properly wait for the first non-null or confirmed null state
    fb_auth.User? fbUser;
    
    // First check if already available
    fbUser = _auth.currentUser;
    
    // If not immediately available, wait for auth state to settle
    if (fbUser == null) {
      // Give Firebase time to restore the persisted auth state
      await Future.delayed(const Duration(milliseconds: 500));
      fbUser = _auth.currentUser;
    }
    
    // Still null? Listen for a short time in case it's still loading
    if (fbUser == null) {
      try {
        await for (final user in _auth.authStateChanges().take(1).timeout(
          const Duration(seconds: 3),
          onTimeout: (sink) => sink.close(),
        )) {
          fbUser = user;
          break;
        }
      } catch (e) {
        print('Auth state check error: $e');
      }
    }

    if (fbUser == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(fbUser.uid).get();
      if (doc.exists) return User.fromJson(doc.data()!);
    } catch (e) {
      print('Error fetching user data: $e');
    }
    return null;
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Update user profile
  Future<User?> updateUserProfile({
    required String userId,
    String? name,
    Uint8List? imageBytes,
    String? imageExtension,
  }) async {
    try {
      Map<String, dynamic> updates = {};

      if (name != null && name.isNotEmpty) {
        updates['name'] = name;
      }

      if (imageBytes != null && imageExtension != null) {
        // Convert image to base64 data URL for fast storage
        final base64Image = base64Encode(imageBytes);
        final mimeType = imageExtension == 'png' ? 'image/png' : 'image/jpeg';
        updates['profilePictureUrl'] = 'data:$mimeType;base64,$base64Image';
      }

      if (updates.isNotEmpty) {
        await _firestore.collection('users').doc(userId).update(updates);
      }

      // Fetch and return updated user
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return User.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Update profile error: $e');
      return null;
    }
  }

  String myCustomHash(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }
}