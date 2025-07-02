import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/user.dart';
import '../services/api_service.dart';
import '../config/constants.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading }

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _token;
  String? _errorMessage;
  bool _rememberMe = false;

  AuthStatus get status => _status;
  User? get user => _user;
  String? get token => _token;
  String? get errorMessage => _errorMessage;
  bool get rememberMe => _rememberMe;
  bool get isAuthenticated =>
      _status == AuthStatus.authenticated && _user != null && _token != null;
  bool get isLoading => _status == AuthStatus.loading;

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      _setStatus(AuthStatus.loading);
      await _loadUserFromStorage();

      if (_token != null) {
        // Verify token with server
        final response = await ApiService().verifyToken();
        if (response['success'] == true) {
          _setStatus(AuthStatus.authenticated);
        } else {
          await _clearUserData();
          _setStatus(AuthStatus.unauthenticated);
        }
      } else {
        _setStatus(AuthStatus.unauthenticated);
      }
    } catch (e) {
      debugPrint('Auth initialization error: $e');
      await _clearUserData();
      _setStatus(AuthStatus.unauthenticated);
    }
  }

  Future<void> _loadUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _rememberMe = prefs.getBool(AppConstants.rememberMeKey) ?? false;

      if (_rememberMe) {
        _token = prefs.getString(AppConstants.tokenKey);

        final userJson = prefs.getString(AppConstants.userKey);
        if (userJson != null) {
          final userData = json.decode(userJson);
          _user = User.fromJson(userData);
        }
      }
    } catch (e) {
      debugPrint('Error loading user from storage: $e');
    }
  }

  Future<void> _saveUserToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (_token != null) {
        await prefs.setString(AppConstants.tokenKey, _token!);
      }

      if (_user != null) {
        await prefs.setString(
          AppConstants.userKey,
          json.encode(_user!.toJson()),
        );
      }

      await prefs.setBool(AppConstants.rememberMeKey, _rememberMe);
    } catch (e) {
      debugPrint('Error saving user to storage: $e');
    }
  }

  Future<void> _clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.tokenKey);
      await prefs.remove(AppConstants.userKey);
      // Don't remove remember me setting on logout, only clear on explicit logout
      if (!_rememberMe) {
        await prefs.remove(AppConstants.rememberMeKey);
      }

      _user = null;
      _token = null;
    } catch (e) {
      debugPrint('Error clearing user data: $e');
    }
  }

  void _setStatus(AuthStatus status) {
    _status = status;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _setError(null);
  }

  Future<bool> login(
    String username,
    String password, {
    bool rememberMe = false,
  }) async {
    try {
      _setStatus(AuthStatus.loading);
      _setError(null);
      _rememberMe = rememberMe;

      final response = await ApiService().login(username, password);

      if (response['token'] != null && response['user'] != null) {
        _token = response['token'];
        _user = User.fromJson(response['user']);

        // Always save to storage to keep user logged in until explicit logout
        await _saveUserToStorage();

        _setStatus(AuthStatus.authenticated);
        return true;
      } else {
        _setError(response['message'] ?? 'Login failed');
        _setStatus(AuthStatus.unauthenticated);
        return false;
      }
    } catch (e) {
      debugPrint('Login error: $e');
      _setError('Login failed. Please try again.');
      _setStatus(AuthStatus.unauthenticated);
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    try {
      _setError(null);
      final response = await ApiService().forgotPassword(email);

      if (response['success'] == true) {
        return true;
      } else {
        _setError(response['message'] ?? 'Failed to send reset email');
        return false;
      }
    } catch (e) {
      debugPrint('Forgot password error: $e');
      _setError('Failed to send reset email. Please try again.');
      return false;
    }
  }

  Future<bool> resetPassword(
    String email,
    String otp,
    String newPassword,
  ) async {
    try {
      _setError(null);
      final response = await ApiService().resetPassword(otp, newPassword);

      if (response['success'] == true) {
        return true;
      } else {
        _setError(response['message'] ?? 'Failed to reset password');
        return false;
      }
    } catch (e) {
      debugPrint('Reset password error: $e');
      _setError('Failed to reset password. Please try again.');
      return false;
    }
  }

  Future<bool> updateProfile(
    String name,
    String username, [
    String? email,
  ]) async {
    try {
      _setError(null);
      final data = {'name': name, 'username': username};

      if (email != null) {
        data['email'] = email;
      }

      final response = await ApiService().updateProfile(data);

      if (response['user'] != null) {
        _user = User.fromJson(response['user']);
        if (_rememberMe) {
          await _saveUserToStorage();
        }
        notifyListeners();
        return true;
      } else {
        _setError(response['message'] ?? 'Failed to update profile');
        return false;
      }
    } catch (e) {
      debugPrint('Update profile error: $e');
      _setError('Failed to update profile. Please try again.');
      return false;
    }
  }

  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      _setError(null);
      final response = await ApiService().changePassword(
        currentPassword,
        newPassword,
      );

      if (response['message'] != null) {
        return true;
      } else {
        _setError(response['message'] ?? 'Failed to change password');
        return false;
      }
    } catch (e) {
      debugPrint('Change password error: $e');
      _setError('Failed to change password. Please try again.');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      _setStatus(AuthStatus.loading);

      // Clear local storage completely
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.tokenKey);
      await prefs.remove(AppConstants.userKey);
      await prefs.remove(AppConstants.rememberMeKey);

      // Reset state
      _user = null;
      _token = null;
      _rememberMe = false;

      // Set status to unauthenticated
      _setStatus(AuthStatus.unauthenticated);
    } catch (e) {
      debugPrint('Logout error: $e');
      // Even if there's an error, we still want to log out locally
      _user = null;
      _token = null;
      _rememberMe = false;
      _setStatus(AuthStatus.unauthenticated);
    }
  }

  Future<void> refreshUser() async {
    if (_token != null) {
      try {
        final response = await ApiService().getUserProfile();
        if (response['success'] == true) {
          _user = User.fromJson(response['user']);
          if (_rememberMe) {
            await _saveUserToStorage();
          }
          notifyListeners();
        }
      } catch (e) {
        debugPrint('Error refreshing user: $e');
      }
    }
  }
}
