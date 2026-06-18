import 'dart:io';

import 'package:flutter/material.dart';
import 'package:temu_disabilitas/models/pendampingan_model.dart';
import 'package:temu_disabilitas/utils/date_helper.dart';

class PendampinganCard extends StatelessWidget {
  final PendampinganModel pendampingan;
  final VoidCallback? onTap;
  final Widget? trailing;

  const PendampinganCard({
    super.key,
    required this.pendampingan,
    this.onTap,
    this.trailing,
  });

  static const _primaryColor = Color(0xFF0F6E56);

  Color _statusColor(String status) {
    if (status.contains('Selesai')) return const Color(0xFF0F6E56);
    if (status.contains('Diterima')) return const Color(0xFF185FA5);
    if (status.contains('Ditolak')) return const Color(0xFFD32F2F);
    if (status.contains('Dipilih')) return const Color(0xFFBA7517);
    return const Color(0xFF888888);
  }

  Color _statusBgColor(String status) {
    if (status.contains('Selesai')) return const Color(0xFFE1F5EE);
    if (status.contains('Diterima')) return const Color(0xFFE6F1FB);
    if (status.contains('Ditolak')) return const Color(0xFFFFEBEB);
    if (status.contains('Dipilih')) return const Color(0xFFFAEEDA);
    return const Color(0xFFF0F0F0);
  }

  IconData _jenisBantuanIcon(String jenis) {
    if (jenis.contains('Publik')) return Icons.account_balance_rounded;
    if (jenis.contains('Pendidikan')) return Icons.school_rounded;
    if (jenis.contains('Transportasi')) return Icons.directions_car_rounded;
    if (jenis.contains('Medis') || jenis.contains('Kesehatan'))
      return Icons.local_hospital_rounded;
    return Icons.volunteer_activism_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label:
          'Pendampingan ${pendampingan.jenisBantuan}, status ${pendampingan.status}',
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE1F5EE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _jenisBantuanIcon(pendampingan.jenisBantuan),
                        size: 18,
                        color: _primaryColor,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        pendampingan.jenisBantuan,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _statusBgColor(pendampingan.status),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        pendampingan.status,
                        style: TextStyle(
                          color: _statusColor(pendampingan.status),
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                if (pendampingan.deskripsi.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    pendampingan.deskripsi,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF555555),
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFFF0F0F0)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 13,
                      color: _primaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateHelper.formatDisplayDate(pendampingan.tanggal),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF555555),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.access_time_rounded,
                      size: 13,
                      color: _primaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      pendampingan.waktu,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF555555),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 13,
                      color: _primaryColor,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        pendampingan.lokasi,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF555555),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (trailing != null) ...[
                  const SizedBox(height: 10),
                  trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileAvatar extends StatelessWidget {
  final String? fotoPath;
  final double radius;
  final String? initials;
  final IconData fallbackIcon;

  const ProfileAvatar({
    super.key,
    this.fotoPath,
    this.radius = 24,
    this.initials,
    this.fallbackIcon = Icons.person,
  });

  @override
  Widget build(BuildContext context) {
    if (fotoPath != null && fotoPath!.isNotEmpty) {
      final file = File(fotoPath!);
      if (file.existsSync()) {
        return CircleAvatar(radius: radius, backgroundImage: FileImage(file));
      }
    }
    if (initials != null && initials!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: const Color(0xFFE1F5EE),
        child: Text(
          initials!,
          style: TextStyle(
            fontSize: radius * 0.55,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0F6E56),
          ),
        ),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFFE1F5EE),
      child: Icon(fallbackIcon, size: radius, color: const Color(0xFF0F6E56)),
    );
  }
}
