import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:temu_disabilitas/models/forum_model.dart';
import 'package:temu_disabilitas/providers/auth_provider.dart';
import 'package:temu_disabilitas/providers/forum_provider.dart';
import 'package:temu_disabilitas/utils/date_helper.dart';
import 'package:temu_disabilitas/widgets/custom_text_field.dart';
import 'package:temu_disabilitas/widgets/loading_widget.dart';
import 'package:temu_disabilitas/widgets/pendampingan_card.dart';

class DetailForumScreen extends StatefulWidget {
  final int forumId;

  const DetailForumScreen({super.key, required this.forumId});

  @override
  State<DetailForumScreen> createState() => _DetailForumScreenState();
}

class _DetailForumScreenState extends State<DetailForumScreen> {
  ForumModel? _post;
  final _komentarController = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _komentarController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final userId = context.read<AuthProvider>().currentUser!.id!;
    final forumProvider = context.read<ForumProvider>();
    _post = await forumProvider.getForumById(widget.forumId, userId);
    await forumProvider.loadKomentar(widget.forumId);
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _addKomentar() async {
    if (_komentarController.text.trim().isEmpty) return;
    final userId = context.read<AuthProvider>().currentUser!.id!;
    await context.read<ForumProvider>().addKomentar(
          widget.forumId,
          userId,
          _komentarController.text,
        );
    _komentarController.clear();
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final forumProvider = context.watch<ForumProvider>();
    final userId = context.read<AuthProvider>().currentUser!.id!;
    final theme = Theme.of(context);

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Postingan')),
        body: const LoadingWidget(),
      );
    }

    if (_post == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Postingan')),
        body: const Center(child: Text('Postingan tidak ditemukan')),
      );
    }

    final post = _post!;

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Postingan')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    ProfileAvatar(fotoPath: post.fotoProfil, radius: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(post.namaUser ?? 'Pengguna',
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          Text(DateHelper.formatDisplayDateTime(post.createdAt)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(post.isiPostingan, style: theme.textTheme.bodyLarge),
                const SizedBox(height: 16),
                Row(
                  children: [
                    InkWell(
                      onTap: () async {
                        await forumProvider.toggleLike(post.id!, userId);
                        await _load();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            Icon(
                              post.isLiked ? Icons.favorite : Icons.favorite_border,
                              color: post.isLiked ? Colors.red : null,
                            ),
                            const SizedBox(width: 4),
                            Text('${post.likeCount} Suka'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Row(
                      children: [
                        const Icon(Icons.comment_outlined),
                        const SizedBox(width: 4),
                        Text('${post.commentCount} Komentar'),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 32),
                Text('Komentar', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                if (forumProvider.komentarList.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('Belum ada komentar'),
                  )
                else
                  ...forumProvider.komentarList.map(
                    (k) => ListTile(
                      leading: ProfileAvatar(fotoPath: k.fotoProfil, radius: 18),
                      title: Text(k.namaUser ?? 'Pengguna'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(k.isiKomentar),
                          Text(
                            DateHelper.formatDisplayDateTime(k.createdAt),
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _komentarController,
                      label: 'Tulis komentar',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    tooltip: 'Kirim komentar',
                    onPressed: _addKomentar,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
