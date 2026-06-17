import 'package:flutter/material.dart';
import 'package:temu_disabilitas/models/forum_model.dart';
import 'package:temu_disabilitas/utils/date_helper.dart';
import 'package:temu_disabilitas/widgets/pendampingan_card.dart';

class ForumPostCard extends StatelessWidget {
  final ForumModel post;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isOwner;

  const ForumPostCard({
    super.key,
    required this.post,
    this.onTap,
    this.onLike,
    this.onComment,
    this.onEdit,
    this.onDelete,
    this.isOwner = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
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
                  ProfileAvatar(fotoPath: post.fotoProfil, radius: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.namaUser ?? 'Pengguna',
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          DateHelper.formatDisplayDateTime(post.createdAt),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (isOwner)
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') onEdit?.call();
                        if (value == 'delete') onDelete?.call();
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'delete', child: Text('Hapus')),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(post.isiPostingan),
              const SizedBox(height: 12),
              Row(
                children: [
                  Semantics(
                    button: true,
                    label: 'Suka postingan, ${post.likeCount} suka',
                    child: InkWell(
                      onTap: onLike,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            Icon(
                              post.isLiked ? Icons.favorite : Icons.favorite_border,
                              color: post.isLiked ? Colors.red : null,
                              size: 22,
                            ),
                            const SizedBox(width: 4),
                            Text('${post.likeCount}'),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Semantics(
                    button: true,
                    label: 'Komentar, ${post.commentCount} komentar',
                    child: InkWell(
                      onTap: onComment,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            const Icon(Icons.comment_outlined, size: 22),
                            const SizedBox(width: 4),
                            Text('${post.commentCount}'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
