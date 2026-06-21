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
  int _unreadCount = 0;

  static const _primaryColor = Color(0xFF0F6E56);
  static const _primaryLight = Color(0xFFE1F5EE);
  static const _secondaryColor = Color(0xFF185FA5);
  static const _secondaryLight = Color(0xFFE6F1FB);
  static const _bgColor = Color(0xFFF8FFFE);

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
    _unreadCount = _notifikasi.where((n) => n.sudahDibaca == 0).length;
    _forum = await forum.loadLatestForum(widget.userId);
    if (mounted) setState(() => _loading = false);
  }

  void _showNotifikasiSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.4),
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.35,
        maxChildSize: 0.85,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 16, 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.notifications_rounded,
                      color: _primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Notifikasi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(
                          context,
                          AppRoutes.notifikasi,
                        ).then((_) => _loadData());
                      },
                      child: const Text(
                        'Lihat semua',
                        style: TextStyle(color: _primaryColor, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: _notifikasi.isEmpty
                    ? const Center(
                        child: Text(
                          'Belum ada notifikasi',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.separated(
                        controller: controller,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _notifikasi.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, indent: 56),
                        itemBuilder: (_, i) {
                          final n = _notifikasi[i];
                          final isUnread = n.sudahDibaca == 0;
                          return ListTile(
                            leading: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: isUnread
                                    ? _primaryLight
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.notifications_rounded,
                                size: 18,
                                color: isUnread ? _primaryColor : Colors.grey,
                              ),
                            ),
                            title: Text(
                              n.judul,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isUnread
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                            subtitle: Text(
                              n.isi,
                              style: const TextStyle(fontSize: 11),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.pushNamed(
                                context,
                                AppRoutes.notifikasi,
                              ).then((_) => _loadData());
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
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
            Text(
              _greeting(),
              style: const TextStyle(
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
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Color(0xFF555555),
                ),
                onPressed: _showNotifikasiSheet,
                tooltip: 'Notifikasi',
              ),
              if (_unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: _primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: _primaryLight,
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _primaryColor,
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
                  // Hero banner
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Semantics(
                      button: true,
                      label: 'Cari pendamping',
                      child: InkWell(
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.buatPermintaan,
                        ).then((_) => _loadData()),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF0F6E56),
                                Color(0xFF1D9E75),
                                Color(0xFF2BB8A0),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Stack(
                            children: [
                              Positioned(
                                right: -10,
                                bottom: -10,
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.08),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 20,
                                top: -15,
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.06),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.volunteer_activism_rounded,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'Butuh pendamping?',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Temukan relawan terbaik di sekitarmu',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.85),
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.35),
                                      ),
                                    ),
                                    child: const Text(
                                      'Cari sekarang →',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Stat cards
                  Container(
                    color: _bgColor,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: _statCard(
                            icon: Icons.calendar_month_rounded,
                            label: 'Jadwal aktif',
                            value: '${_upcoming.length}',
                            bgColor: _primaryLight,
                            iconColor: _primaryColor,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _statCard(
                            icon: Icons.people_rounded,
                            label: 'Notifikasi baru',
                            value: '$_unreadCount',
                            bgColor: _secondaryLight,
                            iconColor: _secondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Jadwal terdekat
                  _sectionHeader(
                    'Jadwal Terdekat',
                    Icons.schedule_rounded,
                    onSeeAll: () {
                      Navigator.pushNamed(context, AppRoutes.penyandangMain);
                    },
                  ),
                  if (_upcoming.isEmpty)
                    _emptyState('Belum ada jadwal pendampingan')
                  else
                    ..._upcoming
                        .take(3)
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

                  // Forum terbaru
                  _sectionHeader(
                    'Forum Terbaru',
                    Icons.forum_rounded,
                    onSeeAll: () {
                      Navigator.pushNamed(context, AppRoutes.penyandangMain);
                    },
                  ),
                  if (_forum.isEmpty)
                    _emptyState('Belum ada postingan forum')
                  else
                    ..._forum.map(
                      (f) => Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 3,
                        ),
                        child: ForumPostCard(
                          post: f,
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.detailForum,
                            arguments: f.id,
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

  Widget _sectionHeader(String title, IconData icon, {VoidCallback? onSeeAll}) {
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
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: const Text(
                'Lihat semua',
                style: TextStyle(fontSize: 11, color: _primaryColor),
              ),
            ),
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

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat pagi ☀️';
    if (hour < 15) return 'Selamat siang 🌤️';
    if (hour < 18) return 'Selamat sore 🌇';
    return 'Selamat malam 🌙';
  }
}
