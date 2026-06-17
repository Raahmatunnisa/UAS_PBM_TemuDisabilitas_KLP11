class ForumModel {
  final int? id;
  final int userId;
  final String isiPostingan;
  final String createdAt;
  final String? namaUser;
  final String? fotoProfil;
  final int likeCount;
  final int commentCount;
  final bool isLiked;

  const ForumModel({
    this.id,
    required this.userId,
    required this.isiPostingan,
    required this.createdAt,
    this.namaUser,
    this.fotoProfil,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'isiPostingan': isiPostingan,
      'createdAt': createdAt,
    };
  }

  factory ForumModel.fromMap(Map<String, dynamic> map) {
    return ForumModel(
      id: map['id'] as int?,
      userId: map['userId'] as int,
      isiPostingan: map['isiPostingan'] as String,
      createdAt: map['createdAt'] as String,
      namaUser: map['namaUser'] as String?,
      fotoProfil: map['fotoProfil'] as String?,
      likeCount: (map['likeCount'] as int?) ?? 0,
      commentCount: (map['commentCount'] as int?) ?? 0,
      isLiked: (map['isLiked'] as int?) == 1,
    );
  }

  ForumModel copyWith({
    int? id,
    int? userId,
    String? isiPostingan,
    String? createdAt,
    String? namaUser,
    String? fotoProfil,
    int? likeCount,
    int? commentCount,
    bool? isLiked,
  }) {
    return ForumModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      isiPostingan: isiPostingan ?? this.isiPostingan,
      createdAt: createdAt ?? this.createdAt,
      namaUser: namaUser ?? this.namaUser,
      fotoProfil: fotoProfil ?? this.fotoProfil,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
