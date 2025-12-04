import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../models/user.dart';
import 'dart:convert';
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
    // Attendre que Firebase Auth ait terminé de restaurer l'état
    fb_auth.User? fbUser = _auth.currentUser;

    // Si null, attendre le premier événement authStateChanges
    if (fbUser == null) {
      fbUser = await _auth.authStateChanges().first;
    }

    if (fbUser == null) return null;

    final doc = await _firestore.collection('users').doc(fbUser.uid).get();
    if (doc.exists) return User.fromJson(doc.data()!);
    return null;
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }
  String myCustomHash(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }
}