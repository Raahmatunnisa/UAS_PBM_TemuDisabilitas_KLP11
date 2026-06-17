import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:temu_disabilitas/models/forum_model.dart';
import 'package:temu_disabilitas/providers/auth_provider.dart';
import 'package:temu_disabilitas/providers/forum_provider.dart';
import 'package:temu_disabilitas/routes/app_routes.dart';
import 'package:temu_disabilitas/widgets/forum_post_card.dart';
import 'package:temu_disabilitas/widgets/loading_widget.dart';

class ForumScreen extends StatefulWidget {
  final bool embedded;

  const ForumScreen({super.key, this.embedded = false});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final userId = context.read<AuthProvider>().currentUser!.id!;
    await context.read<ForumProvider>().loadForum(userId);
  }

  Future<void> _deletePost(ForumModel post) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Postingan'),
        content: const Text('Yakin ingin menghapus postingan ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
        ],
      ),
    );
    if (confirm == true && mounted) {
      final userId = context.read<AuthProvider>().currentUser!.id!;
      await context.read<ForumProvider>().deletePosting(post.id!, userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ForumProvider>();
    final userId = context.read<AuthProvider>().currentUser!.id!;

    return Scaffold(
      appBar: AppBar(title: const Text('Forum Komunitas')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.buatPosting).then((_) => _load()),
        icon: const Icon(Icons.add),
        label: const Text('Posting'),
      ),
      body: provider.isLoading
          ? const LoadingWidget()
          : provider.forumList.isEmpty
              ? RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: const Center(child: Text('Belum ada postingan. Buat postingan pertama!')),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.forumList.length,
                    itemBuilder: (_, index) {
                      final post = provider.forumList[index];
                      return ForumPostCard(
                        post: post,
                        isOwner: post.userId == userId,
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.detailForum,
                          arguments: post.id,
                        ).then((_) => _load()),
                        onLike: () => provider.toggleLike(post.id!, userId),
                        onComment: () => Navigator.pushNamed(
                          context,
                          AppRoutes.detailForum,
                          arguments: post.id,
                        ),
                        onEdit: () => Navigator.pushNamed(
                          context,
                          AppRoutes.editPosting,
                          arguments: post,
                        ).then((_) => _load()),
                        onDelete: () => _deletePost(post),
                      );
                    },
                  ),
                ),
    );
  }
}
