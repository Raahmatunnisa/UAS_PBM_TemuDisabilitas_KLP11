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

  static const _primaryColor = Color(0xFF0F6E56);
  static const _primaryLight = Color(0xFFE1F5EE);
  static const _warmColor = Color(0xFFBA7517);
  static const _warmLight = Color(0xFFFAEEDA);
  static const _bgColor = Color(0xFFF8FFFE);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final provider = context.read<PendampinganProvider>();
    _pending = await provider.getOpenRequests();
    await provider.loadUpcoming(widget.relawanId, isRelawan: true);
    _upcoming = provider.upcomingList;
    _totalSelesai = await provider.countCompleted(widget.relawanId);
    _avgRating = await provider.getAverageRating(widget.relawanId);
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _konfirmasi(PendampinganModel p, bool diterima) async {
    final provider = context.read<PendampinganProvider>();

    if (diterima) {
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
    final initials = user.nama
        .trim()
        .split(' ')
        .take(2)
        .map((e) => e[0].toUpperCase())
        .join();

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dashboard Relawan',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.normal,
              ),
            ),
            Text(
              'Halo, ${user.nama.split(' ').first}!',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: Color(0xFF555555),
            ),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.notifikasi),
            tooltip: 'Notifikasi',
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFEEEDFE),
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF7F77DD),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _loading
          ? const LoadingWidget()
          : RefreshIndicator(
              color: _primaryColor,
              onRefresh: _loadData,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Stat cards
                  Container(
                    color: _bgColor,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: _statCard(
                            icon: Icons.check_circle_rounded,
                            label: 'Selesai',
                            value: '$_totalSelesai',
                            bgColor: _primaryLight,
                            iconColor: _primaryColor,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _statCard(
                            icon: Icons.star_rounded,
                            label: 'Rating',
                            value: _avgRating > 0
                                ? _avgRating.toStringAsFixed(1)
                                : '–',
                            bgColor: _warmLight,
                            iconColor: _warmColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Permintaan masuk
                  _sectionHeader(
                    'Permintaan Masuk',
                    Icons.inbox_rounded,
                    trailing: _pending.isNotEmpty
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _primaryLight,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${_pending.length} baru',
                              style: const TextStyle(
                                fontSize: 10,
                                color: _primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        : null,
                  ),
                  if (_pending.isEmpty)
                    _emptyState('Tidak ada permintaan masuk')
                  else
                    ..._pending.map(
                      (p) => Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 3,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFEEEEEE)),
                          ),
                          child: Column(
                            children: [
                              PendampinganCard(
                                pendampingan: p,
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  AppRoutes.detailPendampingan,
                                  arguments: p.id,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  12,
                                  0,
                                  12,
                                  12,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () => _konfirmasi(p, false),
                                        style: OutlinedButton.styleFrom(
                                          minimumSize: const Size(0, 40),
                                          side: const BorderSide(
                                            color: Color(0xFF1D9E75),
                                          ),
                                          foregroundColor: _primaryColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          'Lewati',
                                          style: TextStyle(fontSize: 13),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: FilledButton(
                                        onPressed: () => _konfirmasi(p, true),
                                        style: FilledButton.styleFrom(
                                          minimumSize: const Size(0, 40),
                                          backgroundColor: _primaryColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          'Terima',
                                          style: TextStyle(fontSize: 13),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Jadwal aktif
                  _sectionHeader('Jadwal Aktif', Icons.calendar_month_rounded),
                  if (_upcoming.isEmpty)
                    _emptyState('Belum ada jadwal aktif')
                  else
                    ..._upcoming
                        .take(5)
                        .map(
                          (p) => Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 3,
                            ),
                            child: PendampinganCard(
                              pendampingan: p,
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.detailPendampingan,
                                arguments: p.id,
                              ),
                            ),
                          ),
                        ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
    required Color bgColor,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: _primaryColor),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const Spacer(),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _emptyState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Text(
        message,
        style: const TextStyle(fontSize: 13, color: Colors.grey),
      ),
    );
  }
}
