import 'package:flutter/material.dart';
import 'package:temu_disabilitas/database/sqlite_helper.dart';
import 'package:temu_disabilitas/models/notifikasi_model.dart';
import 'package:temu_disabilitas/services/notification_service.dart';

class NotifikasiProvider extends ChangeNotifier {
  final SQLiteHelper _db = SQLiteHelper.instance;
  final NotificationService _notificationService = NotificationService.instance;

  List<NotifikasiModel> _notifikasiList = [];
  int _unreadCount = 0;
  bool _isLoading = false;

  List<NotifikasiModel> get notifikasiList => _notifikasiList;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  Future<void> loadNotifikasi(int userId) async {
    _isLoading = true;
    notifyListeners();
    _notifikasiList = await _db.getNotifikasiByUserId(userId);
    _unreadCount = await _db.getUnreadNotifikasiCount(userId);
    _isLoading = false;
    notifyListeners();
  }

  Future<List<NotifikasiModel>> loadLatest(int userId, {int limit = 3}) async {
    return _db.getLatestNotifikasi(userId, limit: limit);
  }

  Future<void> markAsRead(int id, int userId) async {
    await _db.markNotifikasiAsRead(id);
    await loadNotifikasi(userId);
  }

  Future<void> deleteNotifikasi(int id, int userId) async {
    await _db.deleteNotifikasi(id);
    await _notificationService.cancelNotification(id);
    await loadNotifikasi(userId);
  }

  Future<void> refreshUnreadCount(int userId) async {
    _unreadCount = await _db.getUnreadNotifikasiCount(userId);
    notifyListeners();
  }
}
