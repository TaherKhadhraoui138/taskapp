# AuthService - Service d'Authentification

## Fichier: `lib/services/auth_service.dart`

Service gérant l'authentification utilisateur avec Firebase Auth et la gestion des profils dans Firestore.

---

## Dépendances

```dart
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:typed_data';
```

---

## Initialisation

```dart
class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;
}
```

---

## Méthodes

### 1. register() - Inscription

Crée un nouveau compte utilisateur dans Firebase Auth et Firestore.

```dart
Future<User?> register(String email, String password, String name) async {
  try {
    // 1. Créer le compte dans Firebase Auth
    final fb_auth.UserCredential userCredential = 
        await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // 2. Créer l'objet User
    final newUser = User(
      id: userCredential.user!.uid,
      email: email,
      name: name,
      passwordHash: myCustomHash(password)
    );

    // 3. Sauvegarder dans Firestore
    await _firestore
        .collection('users')
        .doc(newUser.id)
        .set(newUser.toJson());
        
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
```

**Flux:**
```
Input: email, password, name
    │
    ▼
Firebase Auth createUserWithEmailAndPassword()
    │
    ├─► Échec (email existe) ──► return null
    │
    ▼
Créer objet User avec ID Firebase
    │
    ▼
Sauvegarder dans Firestore /users/{userId}
    │
    ▼
return User
```

---

### 2. login() - Connexion

Authentifie un utilisateur existant et récupère ses données.

```dart
Future<User?> login(String email, String password) async {
  try {
    // 1. Authentifier via Firebase Auth
    final fb_auth.UserCredential userCredential = 
        await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // 2. Récupérer les données utilisateur depuis Firestore
    final doc = await _firestore
        .collection('users')
        .doc(userCredential.user!.uid)
        .get();

    if (doc.exists) {
      return User.fromJson(doc.data()!);
    }
    return null;
  } catch (e) {
    print('Login error: $e');
    return null;
  }
}
```

**Codes d'erreur Firebase Auth:**
| Code | Description |
|------|-------------|
| `user-not-found` | Email non enregistré |
| `wrong-password` | Mot de passe incorrect |
| `invalid-email` | Format email invalide |
| `user-disabled` | Compte désactivé |

---

### 3. getCurrentUser() - Récupérer l'utilisateur actuel

Vérifie si un utilisateur est déjà connecté (persistance de session).

```dart
Future<User?> getCurrentUser() async {
  fb_auth.User? fbUser;
  
  // Vérifier immédiatement
  fbUser = _auth.currentUser;
  
  // Attendre si pas encore disponible
  if (fbUser == null) {
    await Future.delayed(const Duration(milliseconds: 500));
    fbUser = _auth.currentUser;
  }
  
  // Écouter les changements si toujours null
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

  // Récupérer les données Firestore
  try {
    final doc = await _firestore
        .collection('users')
        .doc(fbUser.uid)
        .get();
    if (doc.exists) return User.fromJson(doc.data()!);
  } catch (e) {
    print('Error fetching user data: $e');
  }
  return null;
}
```

**Utilisation:**
```dart
// Dans SplashScreen
void _checkAuthStatus() async {
  final authService = AuthService();
  await Future.delayed(const Duration(milliseconds: 2500));
  
  final user = await authService.getCurrentUser();

  if (user != null) {
    Navigator.pushReplacement(context, HomeScreen(user: user));
  } else {
    Navigator.pushReplacement(context, LoginScreen());
  }
}
```

---

### 4. logout() - Déconnexion

```dart
Future<void> logout() async {
  await _auth.signOut();
}
```

---

### 5. updateUserProfile() - Mettre à jour le profil

Met à jour le nom et/ou la photo de profil de l'utilisateur.

```dart
Future<User?> updateUserProfile({
  required String userId,
  String? name,
  Uint8List? imageBytes,
  String? imageExtension,
}) async {
  Map<String, dynamic> updates = {};

  // Mise à jour du nom
  if (name != null && name.isNotEmpty) {
    updates['name'] = name;
  }

  // Mise à jour de la photo (convertie en base64)
  if (imageBytes != null && imageExtension != null) {
    final base64Image = base64Encode(imageBytes);
    final mimeType = imageExtension == 'png' ? 'image/png' : 'image/jpeg';
    updates['profilePictureUrl'] = 'data:$mimeType;base64,$base64Image';
  }

  // Appliquer les mises à jour
  if (updates.isNotEmpty) {
    await _firestore
        .collection('users')
        .doc(userId)
        .update(updates);
  }

  // Retourner l'utilisateur mis à jour
  final doc = await _firestore.collection('users').doc(userId).get();
  if (doc.exists) {
    return User.fromJson(doc.data()!);
  }
  return null;
}
```

**Note:** Les images sont stockées en base64 dans Firestore pour simplifier (pas de Firebase Storage nécessaire).

---

### 6. myCustomHash() - Hachage du mot de passe

Fonction utilitaire pour hasher les mots de passe côté client.

```dart
String myCustomHash(String password) {
  return sha256.convert(utf8.encode(password)).toString();
}
```

**Note:** Firebase Auth gère déjà le hachage des mots de passe. Cette fonction est utilisée pour un stockage optionnel dans Firestore.

---

## Diagramme de Flux

```
┌─────────────┐
│   Client    │
└──────┬──────┘
       │
       ▼
┌─────────────────────┐
│    AuthService      │
├─────────────────────┤
│ - register()        │
│ - login()           │
│ - logout()          │
│ - getCurrentUser()  │
│ - updateUserProfile()│
└──────┬──────────────┘
       │
       ├──────────────────┐
       ▼                  ▼
┌─────────────┐    ┌─────────────┐
│ Firebase    │    │ Cloud       │
│ Auth        │    │ Firestore   │
├─────────────┤    ├─────────────┤
│ - Tokens    │    │ - /users    │
│ - Sessions  │    │   - profile │
│ - Password  │    │   - tasks   │
└─────────────┘    └─────────────┘
```

---

## Gestion des Erreurs

```dart
try {
  final user = await authService.login(email, password);
  if (user != null) {
    // Succès
  } else {
    // Échec - afficher message
    _showErrorSnackBar('Login failed. Please check your credentials.');
  }
} catch (e) {
  // Erreur réseau ou autre
  _showErrorSnackBar('An error occurred. Please try again.');
}
```

