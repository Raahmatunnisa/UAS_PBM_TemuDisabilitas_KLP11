import 'package:flutter/material.dart';
import 'package:temu_disabilitas/providers/pendampingan_provider.dart';
import 'package:temu_disabilitas/widgets/pendampingan_card.dart';

class RelawanCard extends StatelessWidget {
  final RelawanWithRating data;
  final VoidCallback? onPilih;

  const RelawanCard({
    super.key,
    required this.data,
    this.onPilih,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final relawan = data.relawan;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ProfileAvatar(fotoPath: relawan.fotoProfil, radius: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        relawan.nama,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            data.averageRating > 0
                                ? '${data.averageRating.toStringAsFixed(1)} (${data.ratingCount} ulasan)'
                                : 'Belum ada rating',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (relawan.keahlian != null && relawan.keahlian!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                children: [
                  Icon(Icons.volunteer_activism, size: 16, color: theme.colorScheme.primary),
                  Text(relawan.keahlian!, style: theme.textTheme.bodyMedium),
                ],
              ),
            ],
            if (relawan.deskripsiRelawan != null && relawan.deskripsiRelawan!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(relawan.deskripsiRelawan!, maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
            if (relawan.jadwalKetersediaan != null && relawan.jadwalKetersediaan!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: theme.colorScheme.secondary),
                  const SizedBox(width: 4),
                  Expanded(child: Text('Jadwal: ${relawan.jadwalKetersediaan}')),
                ],
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onPilih,
                child: const Text('Pilih Relawan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
