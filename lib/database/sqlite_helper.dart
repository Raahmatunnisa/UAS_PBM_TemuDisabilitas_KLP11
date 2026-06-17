import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:temu_disabilitas/models/forum_model.dart';
import 'package:temu_disabilitas/models/komentar_model.dart';
import 'package:temu_disabilitas/models/notifikasi_model.dart';
import 'package:temu_disabilitas/models/pendampingan_model.dart';
import 'package:temu_disabilitas/models/rating_model.dart';
import 'package:temu_disabilitas/models/user_model.dart';
import 'package:temu_disabilitas/utils/constants.dart';

class SQLiteHelper {
  static final SQLiteHelper instance = SQLiteHelper._init();
  static Database? _database;

  SQLiteHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('temudisabilitas.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        telepon TEXT NOT NULL,
        password TEXT NOT NULL,
        role TEXT NOT NULL,
        fotoProfil TEXT,
        jenisDisabilitas TEXT,
        kebutuhanKhusus TEXT,
        keahlian TEXT,
        deskripsiRelawan TEXT,
        jadwalKetersediaan TEXT,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE pendampingan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        relawanId INTEGER,
        jenisBantuan TEXT NOT NULL,
        deskripsi TEXT NOT NULL,
        tanggal TEXT NOT NULL,
        waktu TEXT NOT NULL,
        lokasi TEXT NOT NULL,
        status TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id),
        FOREIGN KEY (relawanId) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE forum (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        isiPostingan TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE komentar (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        forumId INTEGER NOT NULL,
        userId INTEGER NOT NULL,
        isiKomentar TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (forumId) REFERENCES forum (id),
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE likes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        forumId INTEGER NOT NULL,
        userId INTEGER NOT NULL,
        UNIQUE(forumId, userId),
        FOREIGN KEY (forumId) REFERENCES forum (id),
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE rating (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        relawanId INTEGER NOT NULL,
        userId INTEGER NOT NULL,
        nilai INTEGER NOT NULL,
        komentar TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (relawanId) REFERENCES users (id),
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE notifikasi (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        judul TEXT NOT NULL,
        isi TEXT NOT NULL,
        sudahDibaca INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');
  }

  // ==================== USERS ====================

  Future<int> insertUser(UserModel user) async {
    final db = await database;
    return db.insert('users', user.toMap());
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
    );
    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  Future<UserModel?> getUserById(int id) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  Future<bool> isEmailExists(String email) async {
    final user = await getUserByEmail(email);
    return user != null;
  }

  Future<int> updateUser(UserModel user) async {
    final db = await database;
    return db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<List<UserModel>> getRelawanByKeahlian(String jenisBantuan) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'role = ? AND (keahlian LIKE ? OR keahlian LIKE ?)',
      whereArgs: [
        AppConstants.roleRelawan,
        '%$jenisBantuan%',
        '%Lainnya%',
      ],
    );
    return maps.map(UserModel.fromMap).toList();
  }

  Future<List<UserModel>> getAllRelawan() async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'role = ?',
      whereArgs: [AppConstants.roleRelawan],
    );
    return maps.map(UserModel.fromMap).toList();
  }

  // ==================== PENDAMPINGAN ====================

  Future<int> insertPendampingan(PendampinganModel data) async {
    final db = await database;
    return db.insert('pendampingan', data.toMap());
  }

  Future<int> updatePendampingan(PendampinganModel data) async {
    final db = await database;
    return db.update(
      'pendampingan',
      data.toMap(),
      where: 'id = ?',
      whereArgs: [data.id],
    );
  }

  Future<PendampinganModel?> getPendampinganById(int id) async {
    final db = await database;
    final maps = await db.query(
      'pendampingan',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return PendampinganModel.fromMap(maps.first);
  }

  Future<List<PendampinganModel>> getPendampinganByUserId(int userId) async {
    final db = await database;
    final maps = await db.query(
      'pendampingan',
      where: 'userId = ?',
      orderBy: 'tanggal DESC, waktu DESC',
      whereArgs: [userId],
    );
    return maps.map(PendampinganModel.fromMap).toList();
  }

  Future<List<PendampinganModel>> getPendampinganByRelawanId(int relawanId) async {
    final db = await database;
    final maps = await db.query(
      'pendampingan',
      where: 'relawanId = ?',
      orderBy: 'tanggal DESC, waktu DESC',
      whereArgs: [relawanId],
    );
    return maps.map(PendampinganModel.fromMap).toList();
  }

  Future<List<PendampinganModel>> getPendingRequestsForRelawan(int relawanId) async {
    final db = await database;
    final maps = await db.query(
      'pendampingan',
      where: 'relawanId = ? AND status = ?',
      orderBy: 'createdAt DESC',
      whereArgs: [relawanId, AppConstants.statusDipilih],
    );
    return maps.map(PendampinganModel.fromMap).toList();
  }

  Future<List<PendampinganModel>> getUpcomingPendampingan(int userId, {bool isRelawan = false}) async {
    final db = await database;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final column = isRelawan ? 'relawanId' : 'userId';
    final maps = await db.query(
      'pendampingan',
      where: '$column = ? AND tanggal >= ? AND status IN (?, ?)',
      orderBy: 'tanggal ASC, waktu ASC',
      whereArgs: [
        userId,
        today,
        AppConstants.statusDiterima,
        AppConstants.statusDipilih,
      ],
    );
    return maps.map(PendampinganModel.fromMap).toList();
  }

  Future<List<PendampinganModel>> getCompletedPendampingan(int userId, {bool isRelawan = false}) async {
    final db = await database;
    final column = isRelawan ? 'relawanId' : 'userId';
    final maps = await db.query(
      'pendampingan',
      where: '$column = ? AND status = ?',
      orderBy: 'tanggal DESC, waktu DESC',
      whereArgs: [userId, AppConstants.statusSelesai],
    );
    return maps.map(PendampinganModel.fromMap).toList();
  }

  Future<int> countPendampinganByRelawan(int relawanId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM pendampingan WHERE relawanId = ? AND status = ?',
      [relawanId, AppConstants.statusSelesai],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ==================== FORUM ====================

  Future<int> insertForum(ForumModel forum) async {
    final db = await database;
    return db.insert('forum', forum.toMap());
  }

  Future<int> updateForum(ForumModel forum) async {
    final db = await database;
    return db.update(
      'forum',
      forum.toMap(),
      where: 'id = ?',
      whereArgs: [forum.id],
    );
  }

  Future<int> deleteForum(int id) async {
    final db = await database;
    await db.delete('komentar', where: 'forumId = ?', whereArgs: [id]);
    await db.delete('likes', where: 'forumId = ?', whereArgs: [id]);
    return db.delete('forum', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<ForumModel>> getAllForum(int currentUserId) async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT f.*, u.nama as namaUser, u.fotoProfil as fotoProfil,
        (SELECT COUNT(*) FROM likes l WHERE l.forumId = f.id) as likeCount,
        (SELECT COUNT(*) FROM komentar k WHERE k.forumId = f.id) as commentCount,
        (SELECT COUNT(*) FROM likes l WHERE l.forumId = f.id AND l.userId = ?) as isLiked
      FROM forum f
      JOIN users u ON f.userId = u.id
      ORDER BY f.createdAt DESC
    ''', [currentUserId]);
    return maps.map(ForumModel.fromMap).toList();
  }

  Future<List<ForumModel>> getLatestForum(int currentUserId, {int limit = 3}) async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT f.*, u.nama as namaUser, u.fotoProfil as fotoProfil,
        (SELECT COUNT(*) FROM likes l WHERE l.forumId = f.id) as likeCount,
        (SELECT COUNT(*) FROM komentar k WHERE k.forumId = f.id) as commentCount,
        (SELECT COUNT(*) FROM likes l WHERE l.forumId = f.id AND l.userId = ?) as isLiked
      FROM forum f
      JOIN users u ON f.userId = u.id
      ORDER BY f.createdAt DESC
      LIMIT ?
    ''', [currentUserId, limit]);
    return maps.map(ForumModel.fromMap).toList();
  }

  Future<ForumModel?> getForumById(int id, int currentUserId) async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT f.*, u.nama as namaUser, u.fotoProfil as fotoProfil,
        (SELECT COUNT(*) FROM likes l WHERE l.forumId = f.id) as likeCount,
        (SELECT COUNT(*) FROM komentar k WHERE k.forumId = f.id) as commentCount,
        (SELECT COUNT(*) FROM likes l WHERE l.forumId = f.id AND l.userId = ?) as isLiked
      FROM forum f
      JOIN users u ON f.userId = u.id
      WHERE f.id = ?
    ''', [currentUserId, id]);
    if (maps.isEmpty) return null;
    return ForumModel.fromMap(maps.first);
  }

  // ==================== KOMENTAR ====================

  Future<int> insertKomentar(KomentarModel komentar) async {
    final db = await database;
    return db.insert('komentar', komentar.toMap());
  }

  Future<List<KomentarModel>> getKomentarByForumId(int forumId) async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT k.*, u.nama as namaUser, u.fotoProfil as fotoProfil
      FROM komentar k
      JOIN users u ON k.userId = u.id
      WHERE k.forumId = ?
      ORDER BY k.createdAt ASC
    ''', [forumId]);
    return maps.map(KomentarModel.fromMap).toList();
  }

  // ==================== LIKES ====================

  Future<bool> toggleLike(int forumId, int userId) async {
    final db = await database;
    final existing = await db.query(
      'likes',
      where: 'forumId = ? AND userId = ?',
      whereArgs: [forumId, userId],
    );
    if (existing.isNotEmpty) {
      await db.delete(
        'likes',
        where: 'forumId = ? AND userId = ?',
        whereArgs: [forumId, userId],
      );
      return false;
    } else {
      await db.insert('likes', {'forumId': forumId, 'userId': userId});
      return true;
    }
  }

  // ==================== RATING ====================

  Future<int> insertRating(RatingModel rating) async {
    final db = await database;
    return db.insert('rating', rating.toMap());
  }

  Future<double> getAverageRating(int relawanId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT AVG(nilai) as avg FROM rating WHERE relawanId = ?',
      [relawanId],
    );
    final avg = result.first['avg'];
    if (avg == null) return 0.0;
    return (avg as num).toDouble();
  }

  Future<int> getRatingCount(int relawanId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM rating WHERE relawanId = ?',
      [relawanId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<RatingModel>> getRatingsByRelawanId(int relawanId) async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT r.*, u.nama as namaUser
      FROM rating r
      JOIN users u ON r.userId = u.id
      WHERE r.relawanId = ?
      ORDER BY r.createdAt DESC
    ''', [relawanId]);
    return maps.map(RatingModel.fromMap).toList();
  }

  Future<bool> hasRated(int pendampinganUserId, int relawanId) async {
    final db = await database;
    final maps = await db.query(
      'rating',
      where: 'userId = ? AND relawanId = ?',
      whereArgs: [pendampinganUserId, relawanId],
    );
    return maps.isNotEmpty;
  }

  // ==================== NOTIFIKASI ====================

  Future<int> insertNotifikasi(NotifikasiModel notifikasi) async {
    final db = await database;
    return db.insert('notifikasi', notifikasi.toMap());
  }

  Future<List<NotifikasiModel>> getNotifikasiByUserId(int userId) async {
    final db = await database;
    final maps = await db.query(
      'notifikasi',
      where: 'userId = ?',
      orderBy: 'createdAt DESC',
      whereArgs: [userId],
    );
    return maps.map(NotifikasiModel.fromMap).toList();
  }

  Future<List<NotifikasiModel>> getLatestNotifikasi(int userId, {int limit = 3}) async {
    final db = await database;
    final maps = await db.query(
      'notifikasi',
      where: 'userId = ?',
      orderBy: 'createdAt DESC',
      limit: limit,
      whereArgs: [userId],
    );
    return maps.map(NotifikasiModel.fromMap).toList();
  }

  Future<int> markNotifikasiAsRead(int id) async {
    final db = await database;
    return db.update(
      'notifikasi',
      {'sudahDibaca': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteNotifikasi(int id) async {
    final db = await database;
    return db.delete('notifikasi', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> getUnreadNotifikasiCount(int userId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM notifikasi WHERE userId = ? AND sudahDibaca = 0',
      [userId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
