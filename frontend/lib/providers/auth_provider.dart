import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/services.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  Future<void> loadUser() async {
    _user = await AuthService.getCurrentUser();
    notifyListeners();
    if (_user != null) {
      final res = await AuthService.fetchMe();
      if (res['success'] == true && res['user'] != null) {
        _user = UserModel.fromJson(res['user']);
        notifyListeners();
      }
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    final res = await AuthService.login(email, password);
    _isLoading = false;
    if (res['success'] == true) {
      _user = UserModel.fromJson(res['user']);
      notifyListeners();
      return true;
    }
    _error = res['message'] ?? 'Login failed';
    notifyListeners();
    return false;
  }

  Future<bool> register({
    required String name, required String email,
    required String phone, required String password, required String role,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    final res = await AuthService.register(
      name: name, email: email, phone: phone, password: password, role: role,
    );
    _isLoading = false;
    if (res['success'] == true) {
      _user = UserModel.fromJson(res['user']);
      notifyListeners();
      return true;
    }
    _error = res['message'] ?? 'Registration failed';
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    await AuthService.logout();
    _user = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> refreshUser() async {
    final res = await AuthService.fetchMe();
    if (res['success'] == true && res['user'] != null) {
      _user = UserModel.fromJson(res['user']);
      notifyListeners();
    }
  }
}
