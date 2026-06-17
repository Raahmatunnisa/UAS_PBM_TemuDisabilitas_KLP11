import 'package:flutter/material.dart';
import 'package:temu_disabilitas/database/sqlite_helper.dart';
import 'package:temu_disabilitas/models/notifikasi_model.dart';
import 'package:temu_disabilitas/models/pendampingan_model.dart';
import 'package:temu_disabilitas/models/rating_model.dart';
import 'package:temu_disabilitas/models/user_model.dart';
import 'package:temu_disabilitas/services/notification_service.dart';
import 'package:temu_disabilitas/utils/constants.dart';
import 'package:temu_disabilitas/utils/date_helper.dart';

class RelawanWithRating {
  final UserModel relawan;
  final double averageRating;
  final int ratingCount;

  RelawanWithRating({
    required this.relawan,
    required this.averageRating,
    required this.ratingCount,
  });
}

class PendampinganProvider extends ChangeNotifier {
  final SQLiteHelper _db = SQLiteHelper.instance;
  final NotificationService _notificationService = NotificationService.instance;

  List<PendampinganModel> _pendampinganList = [];
  List<PendampinganModel> _upcomingList = [];
  List<PendampinganModel> _completedList = [];
  List<RelawanWithRating> _relawanList = [];
  bool _isLoading = false;

  List<PendampinganModel> get pendampinganList => _pendampinganList;
  List<PendampinganModel> get upcomingList => _upcomingList;
  List<PendampinganModel> get completedList => _completedList;
  List<RelawanWithRating> get relawanList => _relawanList;
  bool get isLoading => _isLoading;

  Future<void> loadPendampinganByUser(int userId) async {
    _isLoading = true;
    notifyListeners();
    _pendampinganList = await _db.getPendampinganByUserId(userId);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadPendampinganByRelawan(int relawanId) async {
    _isLoading = true;
    notifyListeners();
    _pendampinganList = await _db.getPendampinganByRelawanId(relawanId);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadUpcoming(int userId, {bool isRelawan = false}) async {
    _upcomingList = await _db.getUpcomingPendampingan(userId, isRelawan: isRelawan);
    notifyListeners();
  }

  Future<void> loadCompleted(int userId, {bool isRelawan = false}) async {
    _completedList = await _db.getCompletedPendampingan(userId, isRelawan: isRelawan);
    notifyListeners();
  }

  Future<List<PendampinganModel>> getPendingRequests(int relawanId) async {
    return _db.getPendingRequestsForRelawan(relawanId);
  }

  Future<int> countCompleted(int relawanId) async {
    return _db.countPendampinganByRelawan(relawanId);
  }

  Future<double> getAverageRating(int relawanId) async {
    return _db.getAverageRating(relawanId);
  }

  Future<int> createPermintaan({
    required int userId,
    required String jenisBantuan,
    required String deskripsi,
    required String tanggal,
    required String waktu,
    required String lokasi,
  }) async {
    final data = PendampinganModel(
      userId: userId,
      jenisBantuan: jenisBantuan,
      deskripsi: deskripsi,
      tanggal: tanggal,
      waktu: waktu,
      lokasi: lokasi,
      status: AppConstants.statusMenunggu,
      createdAt: DateHelper.nowIso(),
    );
    final id = await _db.insertPendampingan(data);

    await _db.insertNotifikasi(NotifikasiModel(
      userId: userId,
      judul: 'Permintaan Dibuat',
      isi: 'Permintaan pendampingan "$jenisBantuan" berhasil dibuat.',
      createdAt: DateHelper.nowIso(),
    ));

    await _scheduleReminder(id, jenisBantuan, tanggal, waktu);
    notifyListeners();
    return id;
  }

  Future<void> searchRelawan(String jenisBantuan) async {
    _isLoading = true;
    notifyListeners();

    final relawan = await _db.getRelawanByKeahlian(jenisBantuan);
    final withRating = <RelawanWithRating>[];

    for (final r in relawan) {
      final avg = await _db.getAverageRating(r.id!);
      final count = await _db.getRatingCount(r.id!);
      withRating.add(RelawanWithRating(
        relawan: r,
        averageRating: avg,
        ratingCount: count,
      ));
    }

    withRating.sort((a, b) => b.averageRating.compareTo(a.averageRating));
    _relawanList = withRating;
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> pilihRelawan({
    required int pendampinganId,
    required int relawanId,
    required int userId,
    required String jenisBantuan,
  }) async {
    final existing = await _db.getPendampinganById(pendampinganId);
    if (existing == null) return false;

    final updated = existing.copyWith(
      relawanId: relawanId,
      status: AppConstants.statusDipilih,
    );
    await _db.updatePendampingan(updated);

    await _db.insertNotifikasi(NotifikasiModel(
      userId: relawanId,
      judul: 'Permintaan Pendampingan Baru',
      isi: 'Anda dipilih untuk pendampingan "$jenisBantuan". Silakan konfirmasi.',
      createdAt: DateHelper.nowIso(),
    ));

    await _notificationService.showNotification(
      id: relawanId + pendampinganId,
      title: 'Permintaan Pendampingan Baru',
      body: 'Anda dipilih untuk pendampingan "$jenisBantuan".',
    );

    notifyListeners();
    return true;
  }

  Future<bool> konfirmasiPermintaan({
    required int pendampinganId,
    required int userId,
    required bool diterima,
  }) async {
    final existing = await _db.getPendampinganById(pendampinganId);
    if (existing == null) return false;

    final status = diterima ? AppConstants.statusDiterima : AppConstants.statusDitolak;
    await _db.updatePendampingan(existing.copyWith(status: status));

    await _db.insertNotifikasi(NotifikasiModel(
      userId: existing.userId,
      judul: diterima ? 'Permintaan Diterima' : 'Permintaan Ditolak',
      isi: diterima
          ? 'Relawan telah menerima permintaan pendampingan Anda.'
          : 'Relawan menolak permintaan pendampingan Anda.',
      createdAt: DateHelper.nowIso(),
    ));

    if (diterima) {
      await _scheduleReminder(
        pendampinganId,
        existing.jenisBantuan,
        existing.tanggal,
        existing.waktu,
      );
    }

    notifyListeners();
    return true;
  }

  Future<bool> selesaikanPendampingan(int pendampinganId) async {
    final existing = await _db.getPendampinganById(pendampinganId);
    if (existing == null) return false;

    await _db.updatePendampingan(existing.copyWith(status: AppConstants.statusSelesai));
    notifyListeners();
    return true;
  }

  Future<bool> beriRating({
    required int relawanId,
    required int userId,
    required int nilai,
    required String komentar,
  }) async {
    final rating = RatingModel(
      relawanId: relawanId,
      userId: userId,
      nilai: nilai,
      komentar: komentar,
      createdAt: DateHelper.nowIso(),
    );
    await _db.insertRating(rating);
    notifyListeners();
    return true;
  }

  Future<bool> hasRated(int userId, int relawanId) async {
    return _db.hasRated(userId, relawanId);
  }

  Future<void> _scheduleReminder(int id, String jenis, String tanggal, String waktu) async {
    final dateTime = DateHelper.parseDateTime(tanggal, waktu);
    if (dateTime == null) return;

    final reminderTime = dateTime.subtract(const Duration(hours: 1));
    if (reminderTime.isAfter(DateTime.now())) {
      await _notificationService.scheduleReminder(
        id: id,
        title: 'Reminder Pendampingan',
        body: 'Kegiatan "$jenis" akan dimulai dalam 1 jam.',
        scheduledDate: reminderTime,
      );
    }
  }
}
