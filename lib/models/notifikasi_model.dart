class NotifikasiModel {
  final int? id;
  final int userId;
  final String judul;
  final String isi;
  final int sudahDibaca;
  final String createdAt;

  const NotifikasiModel({
    this.id,
    required this.userId,
    required this.judul,
    required this.isi,
    this.sudahDibaca = 0,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'judul': judul,
      'isi': isi,
      'sudahDibaca': sudahDibaca,
      'createdAt': createdAt,
    };
  }

  factory NotifikasiModel.fromMap(Map<String, dynamic> map) {
    return NotifikasiModel(
      id: map['id'] as int?,
      userId: map['userId'] as int,
      judul: map['judul'] as String,
      isi: map['isi'] as String,
      sudahDibaca: map['sudahDibaca'] as int? ?? 0,
      createdAt: map['createdAt'] as String,
    );
  }

  NotifikasiModel copyWith({
    int? id,
    int? userId,
    String? judul,
    String? isi,
    int? sudahDibaca,
    String? createdAt,
  }) {
    return NotifikasiModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      judul: judul ?? this.judul,
      isi: isi ?? this.isi,
      sudahDibaca: sudahDibaca ?? this.sudahDibaca,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
