import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:temu_disabilitas/database/sqlite_helper.dart';
import 'package:temu_disabilitas/models/user_model.dart';
import 'package:temu_disabilitas/utils/constants.dart';
import 'package:temu_disabilitas/utils/date_helper.dart';

class AuthService {
  final SQLiteHelper _db = SQLiteHelper.instance;

  Future<UserModel?> login(String email, String password) async {
    final user = await _db.getUserByEmail(email.trim().toLowerCase());
    if (user == null) return null;
    if (user.password != password) return null;
    await _saveSession(user);
    return user;
  }

  Future<UserModel?> register({
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
    final normalizedEmail = email.trim().toLowerCase();
    if (await _db.isEmailExists(normalizedEmail)) {
      throw Exception('Email sudah terdaftar');
    }

    final user = UserModel(
      nama: nama.trim(),
      email: normalizedEmail,
      telepon: telepon.trim(),
      password: password,
      role: role,
      fotoProfil: fotoProfil,
      jenisDisabilitas: jenisDisabilitas?.trim(),
      kebutuhanKhusus: kebutuhanKhusus?.trim(),
      keahlian: keahlian?.trim(),
      deskripsiRelawan: deskripsiRelawan?.trim(),
      jadwalKetersediaan: jadwalKetersediaan?.trim(),
      createdAt: DateHelper.nowIso(),
    );

    final id = await _db.insertUser(user);
    final savedUser = user.copyWith(id: id);
    await _saveSession(savedUser);
    return savedUser;
  }

  Future<void> _saveSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.sessionLoggedInKey, true);
    await prefs.setInt(AppConstants.sessionUserIdKey, user.id!);
    await prefs.setString(AppConstants.sessionRoleKey, user.role);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.sessionLoggedInKey) ?? false;
  }

  Future<int?> getSessionUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(AppConstants.sessionUserIdKey);
  }

  Future<String?> getSessionRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.sessionRoleKey);
  }

  Future<UserModel?> getCurrentUser() async {
    final userId = await getSessionUserId();
    if (userId == null) return null;
    return _db.getUserById(userId);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.sessionLoggedInKey);
    await prefs.remove(AppConstants.sessionUserIdKey);
    await prefs.remove(AppConstants.sessionRoleKey);
  }
}

class ImageService {
  Future<String?> saveProfileImage(File imageFile, int userId) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final profileDir = Directory(p.join(appDir.path, 'profile_images'));
      if (!await profileDir.exists()) {
        await profileDir.create(recursive: true);
      }
      final extension = p.extension(imageFile.path);
      final fileName = 'profile_$userId$extension';
      final savedFile = await imageFile.copy(p.join(profileDir.path, fileName));
      return savedFile.path;
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteOldImage(String? path) async {
    if (path == null || path.isEmpty) return;
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }
}
