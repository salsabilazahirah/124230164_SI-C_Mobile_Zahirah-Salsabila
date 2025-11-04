import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/database_helper.dart';
import '../services/profile_api_service.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../providers/cart_provider.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final ProfileApiService _profileApi = ProfileApiService();

  // Initialize - check if user is logged in
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('current_user');

      if (userJson != null) {
        final userMap = json.decode(userJson);
        _currentUser = User.fromMap(userMap);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error initializing auth: $e');
    }
  }

  // Login
  Future<bool> login(String usernameOrEmail, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      User? user = await _dbHelper.verifyLogin(usernameOrEmail, password);
      if (user != null) {
        _currentUser = user;
        // Save to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('current_user', json.encode(user.toMap()));
        // Set CartProvider userId agar order history sinkron
        Future.microtask(() {
          try {
            final cartProvider = CartProvider();
            cartProvider.userId = user.id;
          } catch (e) {
            debugPrint('Failed to set CartProvider.userId: $e');
          }
        });
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Username/email atau password salah';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Login failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register
  Future<bool> register({
    required String username,
    required String email,
    required String password,
    String? fullName,
    String? phone,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      // Check if username exists
      if (await _dbHelper.usernameExists(username)) {
        _error = 'Username sudah digunakan';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Check if email exists
      if (await _dbHelper.emailExists(email)) {
        _error = 'Email sudah terdaftar';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final user = User(
        username: username,
        email: email,
        passwordHash: _hashPassword(password),
        fullName: fullName,
        phone: phone,
      );
      final createdUser = await _dbHelper.createUser(user);
      if (createdUser != null) {
        _currentUser = createdUser;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('current_user', json.encode(createdUser.toMap()));
        // Set CartProvider userId agar order history sinkron
        Future.microtask(() {
          try {
            final cartProvider = CartProvider();
            cartProvider.userId = createdUser.id;
          } catch (e) {
            debugPrint('Failed to set CartProvider.userId: $e');
          }
        });
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Registration failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Registration failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _currentUser = null;

    // Clear from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user');

    notifyListeners();
  }

  // Update profile with API
  Future<bool> updateProfile({
    String? fullName,
    String? phone,
    String? email,
    String? profilePicture,
    String? newPassword,
  }) async {
    if (_currentUser == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Try API first if user ID is available
      if (_currentUser!.id != null) {
        final apiResult = await _profileApi.updateProfile(
          userId: _currentUser!.id!,
          fullName: fullName ?? _currentUser!.fullName ?? '',
          profilePicture: profilePicture,
          password: newPassword,
        );

        if (apiResult['success']) {
          // Update local database and current user
          final updatedUser = _currentUser!.copyWith(
            fullName: fullName ?? _currentUser!.fullName,
            phone: phone ?? _currentUser!.phone,
            email: email ?? _currentUser!.email,
            profilePicture: profilePicture ?? _currentUser!.profilePicture,
          );

          await _dbHelper.updateUser(updatedUser);
          _currentUser = updatedUser;

          // Update SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
            'current_user',
            json.encode(updatedUser.toMap()),
          );

          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _error = apiResult['message'] ?? 'Failed to update profile';
        }
      }

      // Fallback to local database only
      final updatedUser = _currentUser!.copyWith(
        fullName: fullName ?? _currentUser!.fullName,
        phone: phone ?? _currentUser!.phone,
        email: email ?? _currentUser!.email,
        profilePicture: profilePicture ?? _currentUser!.profilePicture,
      );

      await _dbHelper.updateUser(updatedUser);
      _currentUser = updatedUser;

      // Update SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user', json.encode(updatedUser.toMap()));

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Update failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete account with API
  Future<bool> deleteAccount() async {
    if (_currentUser == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Try API first if user ID is available
      if (_currentUser!.id != null) {
        final apiResult = await _profileApi.deleteAccount(_currentUser!.id!);

        if (apiResult['success']) {
          // Delete from local database
          await _dbHelper.deleteUser(_currentUser!.id!);

          // Clear current user and preferences
          _currentUser = null;
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('current_user');

          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _error = apiResult['message'] ?? 'Failed to delete account';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }

      // Fallback to local database only
      await _dbHelper.deleteUser(_currentUser!.id!);
      _currentUser = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_user');

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Delete failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Get display name
  String getDisplayName() {
    if (_currentUser == null) return 'Guest';
    return _currentUser!.fullName ?? _currentUser!.username;
  }

  // Local password hashing helper (SHA-256)
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
