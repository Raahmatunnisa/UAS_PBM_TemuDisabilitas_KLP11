import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:temu_disabilitas/models/forum_model.dart';
import 'package:temu_disabilitas/models/notifikasi_model.dart';
import 'package:temu_disabilitas/models/pendampingan_model.dart';
import 'package:temu_disabilitas/providers/auth_provider.dart';
import 'package:temu_disabilitas/providers/forum_provider.dart';
import 'package:temu_disabilitas/providers/notifikasi_provider.dart';
import 'package:temu_disabilitas/providers/pendampingan_provider.dart';
import 'package:temu_disabilitas/routes/app_routes.dart';
import 'package:temu_disabilitas/widgets/forum_post_card.dart';
import 'package:temu_disabilitas/widgets/loading_widget.dart';
import 'package:temu_disabilitas/widgets/notifikasi_card.dart';
import 'package:temu_disabilitas/widgets/pendampingan_card.dart';

class PenyandangHomeTab extends StatefulWidget {
  final int userId;

  const PenyandangHomeTab({super.key, required this.userId});

  @override
  State<PenyandangHomeTab> createState() => _PenyandangHomeTabState();
}

class _PenyandangHomeTabState extends State<PenyandangHomeTab> {
  List<PendampinganModel> _upcoming = [];
  List<NotifikasiModel> _notifikasi = [];
  List<ForumModel> _forum = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final pendampingan = context.read<PendampinganProvider>();
    final notifikasi = context.read<NotifikasiProvider>();
    final forum = context.read<ForumProvider>();

    await pendampingan.loadUpcoming(widget.userId);
    _upcoming = pendampingan.upcomingList;
    _notifikasi = await notifikasi.loadLatest(widget.userId);
    _forum = await forum.loadLatestForum(widget.userId);
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Beranda'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Notifikasi',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.notifikasi).then((_) => _loadData()),
          ),
        ],
      ),
      body: _loading
          ? const LoadingWidget()
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Halo, ${user.nama}!',
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text('Semoga hari Anda menyenangkan'),
                  const SizedBox(height: 20),
                  Semantics(
                    button: true,
                    label: 'Cari pendamping',
                    child: Card(
                      color: theme.colorScheme.primaryContainer,
                      child: InkWell(
                        onTap: () => Navigator.pushNamed(context, AppRoutes.buatPermintaan).then((_) => _loadData()),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Icon(Icons.search, size: 40, color: theme.colorScheme.primary),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Cari Pendamping',
                                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    Text('Buat permintaan pendampingan baru'),
                                  ],
                                ),
                              ),
                              Icon(Icons.arrow_forward_ios, color: theme.colorScheme.primary),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _sectionTitle(context, 'Jadwal Pendampingan Terdekat', Icons.event),
                  if (_upcoming.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('Belum ada jadwal pendampingan'),
                    )
                  else
                    ..._upcoming.take(3).map(
                          (p) => PendampinganCard(
                            pendampingan: p,
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.detailPendampingan,
                              arguments: p.id,
                            ),
                          ),
                        ),
                  const SizedBox(height: 24),
                  _sectionTitle(context, 'Notifikasi Terbaru', Icons.notifications),
                  if (_notifikasi.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('Belum ada notifikasi'),
                    )
                  else
                    ..._notifikasi.map(
                      (n) => NotifikasiCard(
                        notifikasi: n,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.notifikasi),
                      ),
                    ),
                  const SizedBox(height: 24),
                  _sectionTitle(context, 'Forum Terbaru', Icons.forum),
                  if (_forum.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('Belum ada postingan forum'),
                    )
                  else
                    ..._forum.map(
                      (f) => ForumPostCard(
                        post: f,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.detailForum, arguments: f.id),
                      ),
                    ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 22),
        const SizedBox(width: 8),
        Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
