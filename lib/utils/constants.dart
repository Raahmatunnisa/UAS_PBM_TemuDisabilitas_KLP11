class AppConstants {
  static const String appName = 'TemuDisabilitas';

  static const String rolePenyandang = 'Penyandang Disabilitas';
  static const String roleRelawan = 'Relawan';

  static const String statusMenunggu = 'Menunggu Relawan';
  static const String statusDipilih = 'Relawan Dipilih';
  static const String statusDiterima = 'Diterima';
  static const String statusDitolak = 'Ditolak';
  static const String statusSelesai = 'Selesai';

  static const String sessionUserIdKey = 'user_id';
  static const String sessionRoleKey = 'user_role';
  static const String sessionLoggedInKey = 'is_logged_in';

  static const List<String> jenisBantuanList = [
    'Aktivitas Sehari-hari',
    'Kegiatan Pendidikan',
    'Kegiatan Sosial',
    'Layanan Publik',
    'Transportasi',
    'Lainnya',
  ];

  static const List<String> jenisDisabilitasList = [
    'Tunanetra',
    'Tunarungu',
    'Tunadaksa',
    'Disabilitas Intelektual',
    'Disabilitas Mental',
    'Lainnya',
  ];
}
