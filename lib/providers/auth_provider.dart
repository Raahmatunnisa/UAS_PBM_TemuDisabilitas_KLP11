import 'package:flutter/material.dart';
import 'package:temu_disabilitas/models/user_model.dart';
import 'package:temu_disabilitas/services/auth_service.dart';
import 'package:temu_disabilitas/utils/constants.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;
  bool get isPenyandang => _currentUser?.role == AppConstants.rolePenyandang;
  bool get isRelawan => _currentUser?.role == AppConstants.roleRelawan;

  Future<bool> checkSession() async {
    _isLoading = true;
    notifyListeners();
    try {
      final loggedIn = await _authService.isLoggedIn();
      if (loggedIn) {
        _currentUser = await _authService.getCurrentUser();
      }
      return _currentUser != null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final user = await _authService.login(email, password);
      if (user == null) {
        _error = 'Email atau password salah';
        return false;
      }
      _currentUser = user;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String nama,
    required String email,
    required String telepon,
    required String password,
    required String role,
    String? fotoProfil,
    String? jenisDisabilitas,
    String? kebutuhanKhusus,
    String? keahlian,
    String? deskripsiRelawan,
    String? jadwalKetersediaan,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final user = await _authService.register(
        nama: nama,
        email: email,
        telepon: telepon,
        password: password,
        role: role,
        fotoProfil: fotoProfil,
        jenisDisabilitas: jenisDisabilitas,
        kebutuhanKhusus: kebutuhanKhusus,
        keahlian: keahlian,
        deskripsiRelawan: deskripsiRelawan,
        jadwalKetersediaan: jadwalKetersediaan,
      );
      _currentUser = user;
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    notifyListeners();
  }

  void updateCurrentUser(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
