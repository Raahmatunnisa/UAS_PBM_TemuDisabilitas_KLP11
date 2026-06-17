import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:temu_disabilitas/providers/auth_provider.dart';
import 'package:temu_disabilitas/providers/pendampingan_provider.dart';
import 'package:temu_disabilitas/routes/app_routes.dart';
import 'package:temu_disabilitas/widgets/loading_widget.dart';
import 'package:temu_disabilitas/widgets/relawan_card.dart';

class CariRelawanScreen extends StatefulWidget {
  final int pendampinganId;
  final String jenisBantuan;

  const CariRelawanScreen({
    super.key,
    required this.pendampinganId,
    required this.jenisBantuan,
  });

  @override
  State<CariRelawanScreen> createState() => _CariRelawanScreenState();
}

class _CariRelawanScreenState extends State<CariRelawanScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PendampinganProvider>().searchRelawan(widget.jenisBantuan);
    });
  }

  Future<void> _pilihRelawan(int relawanId) async {
    final user = context.read<AuthProvider>().currentUser!;
    final provider = context.read<PendampinganProvider>();

    final success = await provider.pilihRelawan(
      pendampinganId: widget.pendampinganId,
      relawanId: relawanId,
      userId: user.id!,
      jenisBantuan: widget.jenisBantuan,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Relawan berhasil dipilih')),
      );
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.penyandangMain,
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PendampinganProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Pilih Relawan')),
      body: provider.isLoading
          ? const LoadingWidget(message: 'Mencari relawan...')
          : provider.relawanList.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.person_search, size: 64),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada relawan dengan keahlian "${widget.jenisBantuan}"',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Kembali'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.relawanList.length,
                  itemBuilder: (_, index) {
                    final data = provider.relawanList[index];
                    return RelawanCard(
                      data: data,
                      onPilih: () => _pilihRelawan(data.relawan.id!),
                    );
                  },
                ),
    );
  }
}
