import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:temu_disabilitas/providers/auth_provider.dart';
import 'package:temu_disabilitas/providers/notifikasi_provider.dart';
import 'package:temu_disabilitas/widgets/loading_widget.dart';
import 'package:temu_disabilitas/widgets/notifikasi_card.dart';

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final userId = context.read<AuthProvider>().currentUser!.id!;
    await context.read<NotifikasiProvider>().loadNotifikasi(userId);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotifikasiProvider>();
    final userId = context.read<AuthProvider>().currentUser!.id!;

    return Scaffold(
      appBar: AppBar(title: const Text('Notifikasi')),
      body: provider.isLoading
          ? const LoadingWidget()
          : provider.notifikasiList.isEmpty
          ? RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: const Center(child: Text('Belum ada notifikasi')),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: provider.notifikasiList.length,
                itemBuilder: (_, index) {
                  final n = provider.notifikasiList[index];
                  return NotifikasiCard(
                    notifikasi: n,
                    onTap: () => provider.markAsRead(n.id!, userId),
                    onDelete: () => provider.deleteNotifikasi(n.id!, userId),
                  );
                },
              ),
            ),
    );
  }
}
