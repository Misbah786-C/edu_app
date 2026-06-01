import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../enums/app_enums.dart';
import '../models/user_model.dart';

class AuthController with ChangeNotifier {
  // ── State ──────────────────────────────────────────────────────────────────
  AuthState _state = AuthState.unauthenticated;
  UserModel? _currentUser;
  String _errorMessage = '';

  AuthState get state => _state;
  UserModel? get currentUser => _currentUser;
  String get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isLoading => _state == AuthState.loading;

  // In-memory "database" of registered users (keyed by email)
  final Map<String, UserModel> _registeredUsers = {};

  // ── Initialise – restore session ──────────────────────────────────────────
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('session_user');
    if (raw != null) {
      try {
        final map = json.decode(raw) as Map<String, dynamic>;
        _currentUser = UserModel.fromMap(map);
        _state = AuthState.authenticated;
        notifyListeners();
      } catch (_) {
        await prefs.remove('session_user');
      }
    }
  }

  // ── Register ──────────────────────────────────────────────────────────────
  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required Gender gender,
    required String password,
  }) async {
    _setState(AuthState.loading);
    await Future.delayed(const Duration(milliseconds: 800)); // simulate network

    final key = email.toLowerCase().trim();

    if (_registeredUsers.containsKey(key)) {
      _setError('An account with this email already exists.');
      return false;
    }

    final user = UserModel(
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      email: key,
      gender: gender,
      password: password,
    );
    _registeredUsers[key] = user;
    _setState(AuthState.unauthenticated);
    return true;
  }

  // ── Login ─────────────────────────────────────────────────────────────────
  Future<bool> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    _setState(AuthState.loading);
    await Future.delayed(const Duration(milliseconds: 900));

    final key = email.toLowerCase().trim();
    final user = _registeredUsers[key];

    if (user == null || user.password != password) {
      _setError('Invalid email or password. Please try again.');
      return false;
    }

    _currentUser = user;
    _setState(AuthState.authenticated);

    if (rememberMe) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('session_user', json.encode(user.toMap()));
    }
    return true;
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('session_user');
    _currentUser = null;
    _setState(AuthState.unauthenticated);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  void _setState(AuthState s) {
    _state = s;
    if (s != AuthState.error) _errorMessage = '';
    notifyListeners();
  }

  void _setError(String msg) {
    _errorMessage = msg;
    _state = AuthState.error;
    notifyListeners();
  }

  void clearError() {
    if (_state == AuthState.error) {
      _setState(AuthState.unauthenticated);
    }
  }
}