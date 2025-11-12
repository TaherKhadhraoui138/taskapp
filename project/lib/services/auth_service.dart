import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';

class AuthService {
  static const _userKey = 'currentUser';
  static const _registeredUsersKey = 'registeredUsers';

  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    if (userData != null) {
      return User.fromJson(jsonDecode(userData));
    }
    return null;
  }

  Future<List<User>> _loadRegisteredUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersData = prefs.getStringList(_registeredUsersKey) ?? [];
    return usersData.map((data) => User.fromJson(jsonDecode(data))).toList();
  }

  Future<void> _saveRegisteredUsers(List<User> users) async {
    final prefs = await SharedPreferences.getInstance();
    final usersData = users.map((user) => jsonEncode(user.toJson())).toList();
    await prefs.setStringList(_registeredUsersKey, usersData);
  }

  Future<User?> register(String email, String password, String name) async {
    final users = await _loadRegisteredUsers();
    if (users.any((user) => user.email == email)) {
      return null;
    }

    final newUser = User(
      id: const Uuid().v4(),
      email: email,
      name: name,
      password: password,
    );
    users.add(newUser);
    await _saveRegisteredUsers(users);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(newUser.toJson()));
    return newUser;
  }

  Future<User?> login(String email, String password) async {
    final users = await _loadRegisteredUsers();
    final user = users.firstWhere(
          (u) => u.email == email && u.password == password,
      orElse: () => User(id: '', email: '', name: ''),
    );

    if (user.id.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
      return user;
    }
    return null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
}
