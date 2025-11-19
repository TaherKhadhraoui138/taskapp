import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../models/user.dart';

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

  // Get current user
  Future<User?> getCurrentUser() async {
    final fb_auth.User? fbUser = _auth.currentUser;
    if (fbUser == null) return null;

    final doc = await _firestore.collection('users').doc(fbUser.uid).get();
    if (doc.exists) return User.fromJson(doc.data()!);
    return null;
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}