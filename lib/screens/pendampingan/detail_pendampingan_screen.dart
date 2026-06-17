import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:temu_disabilitas/database/sqlite_helper.dart';
import 'package:temu_disabilitas/models/pendampingan_model.dart';
import 'package:temu_disabilitas/models/user_model.dart';
import 'package:temu_disabilitas/providers/auth_provider.dart';
import 'package:temu_disabilitas/providers/pendampingan_provider.dart';
import 'package:temu_disabilitas/routes/app_routes.dart';
import 'package:temu_disabilitas/utils/constants.dart';
import 'package:temu_disabilitas/widgets/loading_widget.dart';
import 'package:temu_disabilitas/widgets/pendampingan_card.dart';

class DetailPendampinganScreen extends StatefulWidget {
  final int pendampinganId;

  const DetailPendampinganScreen({super.key, required this.pendampinganId});

  @override
  State<DetailPendampinganScreen> createState() => _DetailPendampinganScreenState();
}

class _DetailPendampinganScreenState extends State<DetailPendampinganScreen> {
  PendampinganModel? _data;
  UserModel? _penyandang;
  UserModel? _relawan;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = SQLiteHelper.instance;
    _data = await db.getPendampinganById(widget.pendampinganId);
    if (_data != null) {
      _penyandang = await db.getUserById(_data!.userId);
      if (_data!.relawanId != null) {
        _relawan = await db.getUserById(_data!.relawanId!);
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _selesaikan() async {
    final provider = context.read<PendampinganProvider>();
    await provider.selesaikanPendampingan(widget.pendampinganId);
    await _load();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pendampingan ditandai selesai')),
      );
    }
  }

  Future<void> _beriRating() async {
    if (_data?.relawanId == null) return;
    await Navigator.pushNamed(
      context,
      AppRoutes.rating,
      arguments: {
        'pendampinganId': widget.pendampinganId,
        'relawanId': _data!.relawanId,
      },
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Pendampingan')),
        body: const LoadingWidget(),
      );
    }

    if (_data == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Pendampingan')),
        body: const Center(child: Text('Data tidak ditemukan')),
      );
    }

    final auth = context.watch<AuthProvider>();
    final isPenyandang = auth.isPenyandang;
    final isRelawan = auth.isRelawan;
    final theme = Theme.of(context);
    final p = _data!;

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pendampingan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PendampinganCard(pendampingan: p),
            const SizedBox(height: 16),
            if (_penyandang != null) ...[
              Text('Penyandang Disabilitas', style: theme.textTheme.titleSmall),
              ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(_penyandang!.nama),
                subtitle: Text(_penyandang!.telepon),
              ),
            ],
            if (_relawan != null) ...[
              Text('Relawan', style: theme.textTheme.titleSmall),
              ListTile(
                leading: const CircleAvatar(child: Icon(Icons.volunteer_activism)),
                title: Text(_relawan!.nama),
                subtitle: Text(_relawan!.telepon),
              ),
            ],
            const SizedBox(height: 16),
            if (isRelawan && p.status == AppConstants.statusDipilih) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        await context.read<PendampinganProvider>().konfirmasiPermintaan(
                              pendampinganId: p.id!,
                              userId: auth.currentUser!.id!,
                              diterima: false,
                            );
                        await _load();
                      },
                      child: const Text('Tolak'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () async {
                        await context.read<PendampinganProvider>().konfirmasiPermintaan(
                              pendampinganId: p.id!,
                              userId: auth.currentUser!.id!,
                              diterima: true,
                            );
                        await _load();
                      },
                      child: const Text('Terima'),
                    ),
                  ),
                ],
              ),
            ],
            if ((isPenyandang || isRelawan) &&
                p.status == AppConstants.statusDiterima) ...[
              FilledButton.icon(
                onPressed: _selesaikan,
                icon: const Icon(Icons.check),
                label: const Text('Tandai Selesai'),
              ),
            ],
            if (isPenyandang &&
                p.status == AppConstants.statusSelesai &&
                p.relawanId != null) ...[
              const SizedBox(height: 12),
              FutureBuilder<bool>(
                future: context.read<PendampinganProvider>().hasRated(
                      auth.currentUser!.id!,
                      p.relawanId!,
                    ),
                builder: (context, snapshot) {
                  if (snapshot.data == true) {
                    return const Text('Anda sudah memberikan rating');
                  }
                  return FilledButton.icon(
                    onPressed: _beriRating,
                    icon: const Icon(Icons.star),
                    label: const Text('Beri Rating & Ulasan'),
                  );
                },
              ),
            ],
            if (isPenyandang && p.status == AppConstants.statusMenunggu) ...[
              FilledButton.icon(
                onPressed: () => Navigator.pushNamed(
                  context,
                  AppRoutes.cariRelawan,
                  arguments: {
                    'pendampinganId': p.id,
                    'jenisBantuan': p.jenisBantuan,
                  },
                ),
                icon: const Icon(Icons.search),
                label: const Text('Cari Relawan'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
