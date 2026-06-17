import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:temu_disabilitas/models/forum_model.dart';
import 'package:temu_disabilitas/providers/forum_provider.dart';
import 'package:temu_disabilitas/utils/validators.dart';
import 'package:temu_disabilitas/widgets/custom_button.dart';
import 'package:temu_disabilitas/widgets/custom_text_field.dart';

class EditPostingScreen extends StatefulWidget {
  final ForumModel post;

  const EditPostingScreen({super.key, required this.post});

  @override
  State<EditPostingScreen> createState() => _EditPostingScreenState();
}

class _EditPostingScreenState extends State<EditPostingScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _isiController;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _isiController = TextEditingController(text: widget.post.isiPostingan);
  }

  @override
  void dispose() {
    _isiController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final updated = widget.post.copyWith(isiPostingan: _isiController.text.trim());
    await context.read<ForumProvider>().updatePosting(updated);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Postingan')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _isiController,
                label: 'Isi Postingan',
                maxLines: 6,
                validator: (v) => Validators.validateRequired(v, 'Isi postingan'),
              ),
              const SizedBox(height: 24),
              CustomButton(
                label: 'Simpan Perubahan',
                isLoading: _submitting,
                onPressed: _submit,
                icon: Icons.save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
