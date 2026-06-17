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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnread = notifikasi.sudahDibaca == 0;

    return Dismissible(
      key: Key('notif_${notifikasi.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: theme.colorScheme.error,
        child: Icon(Icons.delete, color: theme.colorScheme.onError),
      ),
      child: Card(
        color: isUnread
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
            : null,
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          onTap: onTap,
          leading: CircleAvatar(
            backgroundColor: isUnread
                ? theme.colorScheme.primary
                : theme.colorScheme.surfaceContainerHighest,
            child: Icon(
              Icons.notifications,
              color: isUnread ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
            ),
          ),
          title: Text(
            notifikasi.judul,
            style: TextStyle(fontWeight: isUnread ? FontWeight.bold : FontWeight.normal),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(notifikasi.isi),
              const SizedBox(height: 4),
              Text(
                DateHelper.formatDisplayDateTime(notifikasi.createdAt),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: onDelete,
            tooltip: 'Hapus notifikasi',
          ),
        ),
      ),
    );
  }
}
