class UserModel {
  final int? id;
  final String nama;
  final String email;
  final String telepon;
  final String password;
  final String role;
  final String? fotoProfil;
  final String? jenisDisabilitas;
  final String? kebutuhanKhusus;
  final String? keahlian;
  final String? deskripsiRelawan;
  final String? jadwalKetersediaan;
  final String createdAt;

  const UserModel({
    this.id,
    required this.nama,
    required this.email,
    required this.telepon,
    required this.password,
    required this.role,
    this.fotoProfil,
    this.jenisDisabilitas,
    this.kebutuhanKhusus,
    this.keahlian,
    this.deskripsiRelawan,
    this.jadwalKetersediaan,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'email': email,
      'telepon': telepon,
      'password': password,
      'role': role,
      'fotoProfil': fotoProfil,
      'jenisDisabilitas': jenisDisabilitas,
      'kebutuhanKhusus': kebutuhanKhusus,
      'keahlian': keahlian,
      'deskripsiRelawan': deskripsiRelawan,
      'jadwalKetersediaan': jadwalKetersediaan,
      'createdAt': createdAt,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      nama: map['nama'] as String,
      email: map['email'] as String,
      telepon: map['telepon'] as String,
      password: map['password'] as String,
      role: map['role'] as String,
      fotoProfil: map['fotoProfil'] as String?,
      jenisDisabilitas: map['jenisDisabilitas'] as String?,
      kebutuhanKhusus: map['kebutuhanKhusus'] as String?,
      keahlian: map['keahlian'] as String?,
      deskripsiRelawan: map['deskripsiRelawan'] as String?,
      jadwalKetersediaan: map['jadwalKetersediaan'] as String?,
      createdAt: map['createdAt'] as String,
    );
  }

  UserModel copyWith({
    int? id,
    String? nama,
    String? email,
    String? telepon,
    String? password,
    String? role,
    String? fotoProfil,
    String? jenisDisabilitas,
    String? kebutuhanKhusus,
    String? keahlian,
    String? deskripsiRelawan,
    String? jadwalKetersediaan,
    String? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      email: email ?? this.email,
      telepon: telepon ?? this.telepon,
      password: password ?? this.password,
      role: role ?? this.role,
      fotoProfil: fotoProfil ?? this.fotoProfil,
      jenisDisabilitas: jenisDisabilitas ?? this.jenisDisabilitas,
      kebutuhanKhusus: kebutuhanKhusus ?? this.kebutuhanKhusus,
      keahlian: keahlian ?? this.keahlian,
      deskripsiRelawan: deskripsiRelawan ?? this.deskripsiRelawan,
      jadwalKetersediaan: jadwalKetersediaan ?? this.jadwalKetersediaan,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
