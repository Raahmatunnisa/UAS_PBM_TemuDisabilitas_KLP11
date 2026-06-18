import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:temu_disabilitas/database/sqlite_helper.dart';
import 'package:temu_disabilitas/providers/auth_provider.dart';
import 'package:temu_disabilitas/providers/user_provider.dart';
import 'package:temu_disabilitas/routes/app_routes.dart';
import 'package:temu_disabilitas/widgets/loading_widget.dart';

class ProfilScreen extends StatefulWidget {
  final bool embedded;

  const ProfilScreen({super.key, this.embedded = false});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  double _avgRating = 0;
  int _ratingCount = 0;
  int _totalSelesai = 0;
  bool _loading = true;

  static const _primaryColor = Color(0xFF0F6E56);
  static const _primaryLight = Color(0xFFE1F5EE);
  static const _secondaryColor = Color(0xFF185FA5);
  static const _secondaryLight = Color(0xFFE6F1FB);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser!;
    await context.read<UserProvider>().loadUser(user.id!);

    if (auth.isRelawan) {
      _avgRating = await SQLiteHelper.instance.getAverageRating(user.id!);
      _ratingCount = await SQLiteHelper.instance.getRatingCount(user.id!);
      _totalSelesai = await SQLiteHelper.instance.countPendampinganByRelawan(
        user.id!,
      );
    }

    if (mounted) setState(() => _loading = false);
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Keluar',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: const Text('Yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (!mounted) return;
      await context.read<AuthProvider>().logout();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user ?? auth.currentUser;

    if (_loading || user == null) {
      return const Scaffold(body: LoadingWidget());
    }

    final initials = user.nama
        .trim()
        .split(' ')
        .take(2)
        .map((e) => e[0].toUpperCase())
        .join();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header gradient
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F6E56), Color(0xFF1D9E75)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(width: 40),
                          const Text(
                            'Profil Saya',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.edit_outlined,
                              color: Colors.white70,
                            ),
                            onPressed: () => Navigator.pushNamed(
                              context,
                              AppRoutes.editProfil,
                            ).then((_) => _load()),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: Text(
                          initials,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        user.nama,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          user.role,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Stats card
            Transform.translate(
              offset: const Offset(0, -20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFEEEEEE)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: auth.isRelawan
                      ? Row(
                          children: [
                            _statItem('$_totalSelesai', 'Selesai'),
                            _divider(),
                            _statItem(
                              _ratingCount > 0
                                  ? _avgRating.toStringAsFixed(1)
                                  : '–',
                              'Rating',
                            ),
                            _divider(),
                            _statItem('$_ratingCount', 'Ulasan'),
                          ],
                        )
                      : Row(
                          children: [
                            _statItem(
                              user.jenisDisabilitas ?? '–',
                              'Disabilitas',
                            ),
                            _divider(),
                            _statItem(user.telepon, 'Telepon'),
                          ],
                        ),
                ),
              ),
            ),

            // Info tiles
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel('Informasi Akun'),
                  _infoTile(
                    Icons.email_outlined,
                    'Email',
                    user.email,
                    _primaryLight,
                    _primaryColor,
                  ),
                  _infoTile(
                    Icons.phone_outlined,
                    'Telepon',
                    user.telepon,
                    _secondaryLight,
                    _secondaryColor,
                  ),

                  if (auth.isPenyandang) ...[
                    if (user.jenisDisabilitas != null)
                      _infoTile(
                        Icons.accessibility_new_rounded,
                        'Jenis Disabilitas',
                        user.jenisDisabilitas!,
                        _primaryLight,
                        _primaryColor,
                      ),
                    if (user.kebutuhanKhusus != null)
                      _infoTile(
                        Icons.medical_information_outlined,
                        'Kebutuhan Khusus',
                        user.kebutuhanKhusus!,
                        _secondaryLight,
                        _secondaryColor,
                      ),
                  ],

                  if (auth.isRelawan) ...[
                    _sectionLabel('Informasi Relawan'),
                    if (user.keahlian != null)
                      _infoTile(
                        Icons.volunteer_activism_outlined,
                        'Keahlian',
                        user.keahlian!,
                        _primaryLight,
                        _primaryColor,
                      ),
                    if (user.deskripsiRelawan != null)
                      _infoTile(
                        Icons.description_outlined,
                        'Deskripsi',
                        user.deskripsiRelawan!,
                        _secondaryLight,
                        _secondaryColor,
                      ),
                    if (user.jadwalKetersediaan != null)
                      _infoTile(
                        Icons.schedule_outlined,
                        'Jadwal Ketersediaan',
                        user.jadwalKetersediaan!,
                        _primaryLight,
                        _primaryColor,
                      ),
                  ],

                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(
                        Icons.logout_rounded,
                        color: Color(0xFFD32F2F),
                      ),
                      label: const Text(
                        'Keluar',
                        style: TextStyle(color: Color(0xFFD32F2F)),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFD32F2F)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        minimumSize: const Size(double.infinity, 52),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(width: 0.5, height: 32, color: const Color(0xFFEEEEEE));
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _infoTile(
    IconData icon,
    String label,
    String value,
    Color bgColor,
    Color iconColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
