import 'package:flutter/material.dart';
import 'package:temu_disabilitas/providers/pendampingan_provider.dart';
import 'package:temu_disabilitas/widgets/pendampingan_card.dart';

class RelawanCard extends StatelessWidget {
  final RelawanWithRating data;
  final VoidCallback? onPilih;

  const RelawanCard({super.key, required this.data, this.onPilih});

  static const _primaryColor = Color(0xFF0F6E56);
  static const _primaryLight = Color(0xFFE1F5EE);
  static const _warmColor = Color(0xFFBA7517);

  @override
  Widget build(BuildContext context) {
    final relawan = data.relawan;
    final initials = relawan.nama
        .trim()
        .split(' ')
        .take(2)
        .map((e) => e[0].toUpperCase())
        .join();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ProfileAvatar(
                  fotoPath: relawan.fotoProfil,
                  radius: 24,
                  initials: initials,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        relawan.nama,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.star_rounded, color: _warmColor, size: 14),
                          const SizedBox(width: 3),
                          Text(
                            data.averageRating > 0
                                ? '${data.averageRating.toStringAsFixed(1)} (${data.ratingCount} ulasan)'
                                : 'Belum ada rating',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF555555),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (relawan.keahlian != null && relawan.keahlian!.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Divider(height: 1, color: Color(0xFFF0F0F0)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.volunteer_activism_rounded,
                      size: 13,
                      color: _primaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      relawan.keahlian!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF555555),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            if (relawan.deskripsiRelawan != null &&
                relawan.deskripsiRelawan!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                relawan.deskripsiRelawan!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: Color(0xFF888888)),
              ),
            ],

            if (relawan.jadwalKetersediaan != null &&
                relawan.jadwalKetersediaan!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.schedule_rounded,
                    size: 13,
                    color: Color(0xFF185FA5),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      relawan.jadwalKetersediaan!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF555555),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onPilih,
                style: FilledButton.styleFrom(
                  backgroundColor: _primaryColor,
                  minimumSize: const Size(double.infinity, 42),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Pilih Relawan Ini',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
