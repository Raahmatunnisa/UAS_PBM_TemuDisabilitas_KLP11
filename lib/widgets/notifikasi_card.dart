import 'package:flutter/material.dart';
import 'package:temu_disabilitas/models/notifikasi_model.dart';
import 'package:temu_disabilitas/utils/date_helper.dart';

class NotifikasiCard extends StatelessWidget {
  final NotifikasiModel notifikasi;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const NotifikasiCard({
    super.key,
    required this.notifikasi,
    this.onTap,
    this.onDelete,
  });

  static const _primaryColor = Color(0xFF0F6E56);
  static const _primaryLight = Color(0xFFE1F5EE);
  static const _secondaryColor = Color(0xFF185FA5);
  static const _secondaryLight = Color(0xFFE6F1FB);
  static const _warmColor = Color(0xFFBA7517);
  static const _warmLight = Color(0xFFFAEEDA);
  static const _errorColor = Color(0xFFD32F2F);
  static const _errorLight = Color(0xFFFFEBEB);

  Color _iconColor(String judul) {
    if (judul.contains('Diterima') || judul.contains('Selesai'))
      return _primaryColor;
    if (judul.contains('Ditolak')) return _errorColor;
    if (judul.contains('Dipilih') || judul.contains('Baru'))
      return _secondaryColor;
    if (judul.contains('Reminder') || judul.contains('Pengingat'))
      return _warmColor;
    return _primaryColor;
  }

  Color _bgColor(String judul) {
    if (judul.contains('Diterima') || judul.contains('Selesai'))
      return _primaryLight;
    if (judul.contains('Ditolak')) return _errorLight;
    if (judul.contains('Dipilih') || judul.contains('Baru'))
      return _secondaryLight;
    if (judul.contains('Reminder') || judul.contains('Pengingat'))
      return _warmLight;
    return _primaryLight;
  }

  IconData _icon(String judul) {
    if (judul.contains('Dibuat')) return Icons.add_circle_outline_rounded;
    if (judul.contains('Diterima')) return Icons.check_circle_outline_rounded;
    if (judul.contains('Ditolak')) return Icons.cancel_outlined;
    if (judul.contains('Dipilih') || judul.contains('Baru'))
      return Icons.person_add_outlined;
    if (judul.contains('Reminder') || judul.contains('Pengingat'))
      return Icons.alarm_rounded;
    if (judul.contains('Selesai')) return Icons.done_all_rounded;
    return Icons.notifications_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final isUnread = notifikasi.sudahDibaca == 0;

    return Dismissible(
      key: Key('notif_${notifikasi.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: _errorLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: _errorColor),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isUnread ? _primaryLight.withOpacity(0.4) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnread
                ? _primaryColor.withOpacity(0.2)
                : const Color(0xFFEEEEEE),
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: _bgColor(notifikasi.judul),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _icon(notifikasi.judul),
                    size: 18,
                    color: _iconColor(notifikasi.judul),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notifikasi.judul,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isUnread
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: const Color(0xFF1A1A1A),
                              ),
                            ),
                          ),
                          if (isUnread)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: _primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        notifikasi.isi,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF555555),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        DateHelper.formatDisplayDateTime(notifikasi.createdAt),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                    color: Colors.grey,
                  ),
                  onPressed: onDelete,
                  tooltip: 'Hapus notifikasi',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
