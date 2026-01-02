import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/user.dart';
import '../database/database_helper.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  // Hash password for security
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Login user
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = DatabaseHelper.instance;
      final user = await db.getUserByEmail(email);

      if (user == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Compare hashed passwords
      final hashedPassword = _hashPassword(password);
      if (user.password == hashedPassword) {
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register new user
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = DatabaseHelper.instance;
      
      // Check if email already exists
      final existingUser = await db.getUserByEmail(email);
      if (existingUser != null) {
        _isLoading = false;
        notifyListeners();
        return {
          'success': false,
          'message': 'Email sudah terdaftar',
        };
      }

      // Create new user with hashed password
      final hashedPassword = _hashPassword(password);
      final user = User(
        name: name,
        email: email,
        password: hashedPassword,
        phone: phone,
        role: 'user',
      );

      final userId = await db.createUser(user);
      
      if (userId > 0) {
        // Auto-login after registration
        final newUser = await db.getUserById(userId);
        _currentUser = newUser;
        _isLoading = false;
        notifyListeners();
        return {
          'success': true,
          'message': 'Registrasi berhasil',
        };
      }

      _isLoading = false;
      notifyListeners();
      return {
        'success': false,
        'message': 'Registrasi gagal',
      };
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    required String name,
    String? phone,
  }) async {
    if (_currentUser == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final db = DatabaseHelper.instance;
      final updatedUser = _currentUser!.copyWith(
        name: name,
        phone: phone,
      );

      final result = await db.updateUser(updatedUser);
      
      if (result > 0) {
        _currentUser = updatedUser;
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  // Check if user is already logged in (for persistence)
  Future<void> checkLoginStatus() async {
    // For now, we don't have persistence
    // In production, you might use shared_preferences
    // to store the user ID and restore the session
  }
}
