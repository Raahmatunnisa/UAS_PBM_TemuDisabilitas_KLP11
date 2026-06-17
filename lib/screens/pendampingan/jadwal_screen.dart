import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:temu_disabilitas/providers/auth_provider.dart';
import 'package:temu_disabilitas/providers/pendampingan_provider.dart';
import 'package:temu_disabilitas/routes/app_routes.dart';
import 'package:temu_disabilitas/widgets/loading_widget.dart';
import 'package:temu_disabilitas/widgets/pendampingan_card.dart';

class JadwalScreen extends StatefulWidget {
  final bool isRelawan;
  final bool embedded;

  const JadwalScreen({
    super.key,
    this.isRelawan = false,
    this.embedded = false,
  });

  @override
  State<JadwalScreen> createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final userId = context.read<AuthProvider>().currentUser!.id!;
    final provider = context.read<PendampinganProvider>();
    await provider.loadUpcoming(userId, isRelawan: widget.isRelawan);
    await provider.loadCompleted(userId, isRelawan: widget.isRelawan);
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PendampinganProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isRelawan ? 'Jadwal Kegiatan' : 'Pendampingan'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Mendatang'),
            Tab(text: 'Selesai'),
          ],
        ),
      ),
      body: _loading
          ? const LoadingWidget()
          : TabBarView(
              controller: _tabController,
              children: [
                _buildList(provider.upcomingList, emptyMsg: 'Tidak ada jadwal mendatang'),
                _buildList(provider.completedList, emptyMsg: 'Belum ada kegiatan selesai'),
              ],
            ),
    );
  }

  Widget _buildList(List<dynamic> list, {required String emptyMsg}) {
    if (list.isEmpty) {
      return RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: Center(child: Text(emptyMsg)),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        itemBuilder: (_, index) {
          final p = list[index];
          return PendampinganCard(
            pendampingan: p,
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.detailPendampingan,
              arguments: p.id,
            ),
          );
        },
      ),
    );
  }
}
