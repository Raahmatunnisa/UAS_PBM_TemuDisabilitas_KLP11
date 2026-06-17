import 'dart:io';

import 'package:flutter/material.dart';
import 'package:temu_disabilitas/database/sqlite_helper.dart';
import 'package:temu_disabilitas/models/user_model.dart';
import 'package:temu_disabilitas/services/auth_service.dart';

class UserProvider extends ChangeNotifier {
  final SQLiteHelper _db = SQLiteHelper.instance;
  final ImageService _imageService = ImageService();

  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;

  Future<void> loadUser(int userId) async {
    _isLoading = true;
    notifyListeners();
    _user = await _db.getUserById(userId);
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateProfile(UserModel updatedUser) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _db.updateUser(updatedUser);
      _user = updatedUser;
      return true;
    } catch (_) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> updateProfileImage(File imageFile, int userId) async {
    final path = await _imageService.saveProfileImage(imageFile, userId);
    if (path != null && _user != null) {
      await _imageService.deleteOldImage(_user!.fotoProfil);
      final updated = _user!.copyWith(fotoProfil: path);
      await _db.updateUser(updated);
      _user = updated;
      notifyListeners();
    }
    return path;
  }

  Future<UserModel?> getUserById(int id) => _db.getUserById(id);
}
