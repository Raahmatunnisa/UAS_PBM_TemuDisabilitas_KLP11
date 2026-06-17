import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:temu_disabilitas/database/sqlite_helper.dart';
import 'package:temu_disabilitas/providers/auth_provider.dart';
import 'package:temu_disabilitas/providers/user_provider.dart';
import 'package:temu_disabilitas/routes/app_routes.dart';
import 'package:temu_disabilitas/widgets/loading_widget.dart';
import 'package:temu_disabilitas/widgets/pendampingan_card.dart';

class ProfilScreen extends StatefulWidget {
  final bool embedded;

  const ProfilScreen({super.key, this.embedded = false});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  double _avgRating = 0;
  int _ratingCount = 0;
  bool _loading = true;

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
    }

    if (mounted) setState(() => _loading = false);
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Keluar')),
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
    final theme = Theme.of(context);

    if (_loading || user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profil')),
        body: const LoadingWidget(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit profil',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.editProfil).then((_) => _load()),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            ProfileAvatar(fotoPath: user.fotoProfil, radius: 56),
            const SizedBox(height: 16),
            Text(user.nama, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            Chip(label: Text(user.role)),
            const SizedBox(height: 24),
            _infoTile(Icons.email, 'Email', user.email),
            _infoTile(Icons.phone, 'Telepon', user.telepon),
            if (auth.isPenyandang) ...[
              if (user.jenisDisabilitas != null)
                _infoTile(Icons.accessibility, 'Jenis Disabilitas', user.jenisDisabilitas!),
              if (user.kebutuhanKhusus != null)
                _infoTile(Icons.medical_information, 'Kebutuhan Khusus', user.kebutuhanKhusus!),
            ],
            if (auth.isRelawan) ...[
              if (user.keahlian != null) _infoTile(Icons.volunteer_activism, 'Keahlian', user.keahlian!),
              if (user.deskripsiRelawan != null)
                _infoTile(Icons.description, 'Deskripsi', user.deskripsiRelawan!),
              if (user.jadwalKetersediaan != null)
                _infoTile(Icons.schedule, 'Jadwal Ketersediaan', user.jadwalKetersediaan!),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.star, color: Colors.amber),
                  title: const Text('Rating Rata-rata'),
                  subtitle: Text(
                    _ratingCount > 0
                        ? '${_avgRating.toStringAsFixed(1)} ($_ratingCount ulasan)'
                        : 'Belum ada ulasan',
                  ),
                ),
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text('Keluar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(value),
      ),
    );
  }
}
