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

  Color _statusColor(BuildContext context, String status) {
    final scheme = Theme.of(context).colorScheme;
    if (status.contains('Selesai')) return Colors.green;
    if (status.contains('Diterima')) return scheme.primary;
    if (status.contains('Ditolak')) return scheme.error;
    if (status.contains('Dipilih')) return Colors.orange;
    return scheme.outline;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: onTap != null,
      label: 'Pendampingan ${pendampingan.jenisBantuan}, status ${pendampingan.status}',
      child: Card(
        elevation: 1,
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        pendampingan.jenisBantuan,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor(context, pendampingan.status).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        pendampingan.status,
                        style: TextStyle(
                          color: _statusColor(context, pendampingan.status),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  pendampingan.deskripsi,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: theme.colorScheme.primary),
                    const SizedBox(width: 4),
                    Text(DateHelper.formatDisplayDate(pendampingan.tanggal)),
                    const SizedBox(width: 12),
                    Icon(Icons.access_time, size: 16, color: theme.colorScheme.primary),
                    const SizedBox(width: 4),
                    Text(pendampingan.waktu),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: theme.colorScheme.primary),
                    const SizedBox(width: 4),
                    Expanded(child: Text(pendampingan.lokasi)),
                  ],
                ),
                if (trailing != null) ...[
                  const SizedBox(height: 12),
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
  final IconData fallbackIcon;

  const ProfileAvatar({
    super.key,
    this.fotoPath,
    this.radius = 24,
    this.fallbackIcon = Icons.person,
  });

  @override
  Widget build(BuildContext context) {
    if (fotoPath != null && fotoPath!.isNotEmpty) {
      final file = File(fotoPath!);
      if (file.existsSync()) {
        return CircleAvatar(
          radius: radius,
          backgroundImage: FileImage(file),
        );
      }
    }
    return CircleAvatar(
      radius: radius,
      child: Icon(fallbackIcon, size: radius),
    );
  }
}
