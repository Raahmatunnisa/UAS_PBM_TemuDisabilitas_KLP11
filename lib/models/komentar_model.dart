class KomentarModel {
  final int? id;
  final int forumId;
  final int userId;
  final String isiKomentar;
  final String createdAt;
  final String? namaUser;
  final String? fotoProfil;

  const KomentarModel({
    this.id,
    required this.forumId,
    required this.userId,
    required this.isiKomentar,
    required this.createdAt,
    this.namaUser,
    this.fotoProfil,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'forumId': forumId,
      'userId': userId,
      'isiKomentar': isiKomentar,
      'createdAt': createdAt,
    };
  }

  factory KomentarModel.fromMap(Map<String, dynamic> map) {
    return KomentarModel(
      id: map['id'] as int?,
      forumId: map['forumId'] as int,
      userId: map['userId'] as int,
      isiKomentar: map['isiKomentar'] as String,
      createdAt: map['createdAt'] as String,
      namaUser: map['namaUser'] as String?,
      fotoProfil: map['fotoProfil'] as String?,
    );
  }
}
