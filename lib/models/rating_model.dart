class RatingModel {
  final int? id;
  final int relawanId;
  final int userId;
  final int nilai;
  final String komentar;
  final String createdAt;
  final String? namaUser;

  const RatingModel({
    this.id,
    required this.relawanId,
    required this.userId,
    required this.nilai,
    required this.komentar,
    required this.createdAt,
    this.namaUser,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'relawanId': relawanId,
      'userId': userId,
      'nilai': nilai,
      'komentar': komentar,
      'createdAt': createdAt,
    };
  }

  factory RatingModel.fromMap(Map<String, dynamic> map) {
    return RatingModel(
      id: map['id'] as int?,
      relawanId: map['relawanId'] as int,
      userId: map['userId'] as int,
      nilai: map['nilai'] as int,
      komentar: map['komentar'] as String,
      createdAt: map['createdAt'] as String,
      namaUser: map['namaUser'] as String?,
    );
  }
}
