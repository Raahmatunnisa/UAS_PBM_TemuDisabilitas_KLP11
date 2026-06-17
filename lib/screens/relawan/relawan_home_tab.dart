import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:temu_disabilitas/models/pendampingan_model.dart';
import 'package:temu_disabilitas/providers/auth_provider.dart';
import 'package:temu_disabilitas/providers/pendampingan_provider.dart';
import 'package:temu_disabilitas/routes/app_routes.dart';
import 'package:temu_disabilitas/widgets/loading_widget.dart';
import 'package:temu_disabilitas/widgets/pendampingan_card.dart';

class RelawanHomeTab extends StatefulWidget {
  final int relawanId;

  const RelawanHomeTab({super.key, required this.relawanId});

  @override
  State<RelawanHomeTab> createState() => _RelawanHomeTabState();
}

class _RelawanHomeTabState extends State<RelawanHomeTab> {
  List<PendampinganModel> _pending = [];
  List<PendampinganModel> _upcoming = [];
  int _totalSelesai = 0;
  double _avgRating = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final provider = context.read<PendampinganProvider>();
    _pending = await provider
        .getOpenRequests(); // ← diubah dari getPendingRequests
    await provider.loadUpcoming(widget.relawanId, isRelawan: true);
    _upcoming = provider.upcomingList;
    _totalSelesai = await provider.countCompleted(widget.relawanId);
    _avgRating = await provider.getAverageRating(widget.relawanId);
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _konfirmasi(PendampinganModel p, bool diterima) async {
    final provider = context.read<PendampinganProvider>();

    if (diterima) {
      // Relawan assign dirinya sendiri ke permintaan ini
      await provider.pilihRelawan(
        pendampinganId: p.id!,
        relawanId: widget.relawanId,
        userId: p.userId,
        jenisBantuan: p.jenisBantuan,
      );
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(diterima ? 'Permintaan diterima' : 'Dilewati')),
      );
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Relawan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.notifikasi),
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
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _statCard(
                          context,
                          'Pendampingan Selesai',
                          '$_totalSelesai',
                          Icons.check_circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _statCard(
                          context,
                          'Rating Rata-rata',
                          _avgRating > 0 ? _avgRating.toStringAsFixed(1) : '-',
                          Icons.star,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Permintaan Masuk',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_pending.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('Tidak ada permintaan masuk'),
                    )
                  else
                    ..._pending.map(
                      (p) => PendampinganCard(
                        pendampingan: p,
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.detailPendampingan,
                          arguments: p.id,
                        ),
                        trailing: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _konfirmasi(p, false),
                                child: const Text('Lewati'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: FilledButton(
                                onPressed: () => _konfirmasi(p, true),
                                child: const Text('Terima'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  Text(
                    'Jadwal Pendampingan',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_upcoming.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('Belum ada jadwal'),
                    )
                  else
                    ..._upcoming
                        .take(5)
                        .map(
                          (p) => PendampinganCard(
                            pendampingan: p,
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.detailPendampingan,
                              arguments: p.id,
                            ),
                          ),
                        ),
                ],
              ),
            ),
    );
  }

  Widget _statCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
