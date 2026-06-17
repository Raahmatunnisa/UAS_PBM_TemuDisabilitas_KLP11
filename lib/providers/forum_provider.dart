import 'package:flutter/material.dart';
import 'package:temu_disabilitas/database/sqlite_helper.dart';
import 'package:temu_disabilitas/models/forum_model.dart';
import 'package:temu_disabilitas/models/komentar_model.dart';
import 'package:temu_disabilitas/utils/date_helper.dart';

class ForumProvider extends ChangeNotifier {
  final SQLiteHelper _db = SQLiteHelper.instance;

  List<ForumModel> _forumList = [];
  List<KomentarModel> _komentarList = [];
  bool _isLoading = false;

  List<ForumModel> get forumList => _forumList;
  List<KomentarModel> get komentarList => _komentarList;
  bool get isLoading => _isLoading;

  Future<void> loadForum(int currentUserId) async {
    _isLoading = true;
    notifyListeners();
    _forumList = await _db.getAllForum(currentUserId);
    _isLoading = false;
    notifyListeners();
  }

  Future<List<ForumModel>> loadLatestForum(int currentUserId, {int limit = 3}) async {
    return _db.getLatestForum(currentUserId, limit: limit);
  }

  Future<bool> createPosting(int userId, String isi) async {
    final forum = ForumModel(
      userId: userId,
      isiPostingan: isi.trim(),
      createdAt: DateHelper.nowIso(),
    );
    await _db.insertForum(forum);
    await loadForum(userId);
    return true;
  }

  Future<bool> updatePosting(ForumModel forum) async {
    await _db.updateForum(forum);
    await loadForum(forum.userId);
    return true;
  }

  Future<bool> deletePosting(int forumId, int currentUserId) async {
    await _db.deleteForum(forumId);
    await loadForum(currentUserId);
    return true;
  }

  Future<bool> toggleLike(int forumId, int userId) async {
    await _db.toggleLike(forumId, userId);
    await loadForum(userId);
    return true;
  }

  Future<void> loadKomentar(int forumId) async {
    _komentarList = await _db.getKomentarByForumId(forumId);
    notifyListeners();
  }

  Future<bool> addKomentar(int forumId, int userId, String isi) async {
    final komentar = KomentarModel(
      forumId: forumId,
      userId: userId,
      isiKomentar: isi.trim(),
      createdAt: DateHelper.nowIso(),
    );
    await _db.insertKomentar(komentar);
    await loadKomentar(forumId);
    await loadForum(userId);
    return true;
  }

  Future<ForumModel?> getForumById(int id, int currentUserId) async {
    return _db.getForumById(id, currentUserId);
  }
}
