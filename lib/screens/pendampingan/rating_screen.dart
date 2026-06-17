import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:temu_disabilitas/providers/auth_provider.dart';
import 'package:temu_disabilitas/providers/pendampingan_provider.dart';
import 'package:temu_disabilitas/utils/validators.dart';
import 'package:temu_disabilitas/widgets/custom_button.dart';
import 'package:temu_disabilitas/widgets/custom_text_field.dart';

class RatingScreen extends StatefulWidget {
  final int pendampinganId;
  final int relawanId;

  const RatingScreen({
    super.key,
    required this.pendampinganId,
    required this.relawanId,
  });

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  final _komentarController = TextEditingController();
  int _rating = 5;
  bool _submitting = false;

  @override
  void dispose() {
    _komentarController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_komentarController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ulasan wajib diisi')),
      );
      return;
    }

    setState(() => _submitting = true);
    final user = context.read<AuthProvider>().currentUser!;
    await context.read<PendampinganProvider>().beriRating(
          relawanId: widget.relawanId,
          userId: user.id!,
          nilai: _rating,
          komentar: _komentarController.text,
        );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rating berhasil dikirim')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Beri Rating & Ulasan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Berikan rating untuk relawan:'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final star = index + 1;
                return Semantics(
                  button: true,
                  label: 'Rating $star dari 5',
                  child: IconButton(
                    iconSize: 40,
                    onPressed: () => setState(() => _rating = star),
                    icon: Icon(
                      star <= _rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                  ),
                );
              }),
            ),
            Text('Rating: $_rating / 5', textAlign: TextAlign.center),
            const SizedBox(height: 24),
            CustomTextField(
              controller: _komentarController,
              label: 'Ulasan',
              maxLines: 4,
              validator: (v) => Validators.validateRequired(v, 'Ulasan'),
            ),
            const SizedBox(height: 24),
            CustomButton(
              label: 'Kirim Rating',
              isLoading: _submitting,
              onPressed: _submit,
              icon: Icons.send,
            ),
          ],
        ),
      ),
    );
  }
}
