class PendampinganModel {
  final int? id;
  final int userId;
  final int? relawanId;
  final String jenisBantuan;
  final String deskripsi;
  final String tanggal;
  final String waktu;
  final String lokasi;
  final String status;
  final String createdAt;

  const PendampinganModel({
    this.id,
    required this.userId,
    this.relawanId,
    required this.jenisBantuan,
    required this.deskripsi,
    required this.tanggal,
    required this.waktu,
    required this.lokasi,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'relawanId': relawanId,
      'jenisBantuan': jenisBantuan,
      'deskripsi': deskripsi,
      'tanggal': tanggal,
      'waktu': waktu,
      'lokasi': lokasi,
      'status': status,
      'createdAt': createdAt,
    };
  }

  factory PendampinganModel.fromMap(Map<String, dynamic> map) {
    return PendampinganModel(
      id: map['id'] as int?,
      userId: map['userId'] as int,
      relawanId: map['relawanId'] as int?,
      jenisBantuan: map['jenisBantuan'] as String,
      deskripsi: map['deskripsi'] as String,
      tanggal: map['tanggal'] as String,
      waktu: map['waktu'] as String,
      lokasi: map['lokasi'] as String,
      status: map['status'] as String,
      createdAt: map['createdAt'] as String,
    );
  }

  PendampinganModel copyWith({
    int? id,
    int? userId,
    int? relawanId,
    String? jenisBantuan,
    String? deskripsi,
    String? tanggal,
    String? waktu,
    String? lokasi,
    String? status,
    String? createdAt,
  }) {
    return PendampinganModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      relawanId: relawanId ?? this.relawanId,
      jenisBantuan: jenisBantuan ?? this.jenisBantuan,
      deskripsi: deskripsi ?? this.deskripsi,
      tanggal: tanggal ?? this.tanggal,
      waktu: waktu ?? this.waktu,
      lokasi: lokasi ?? this.lokasi,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
