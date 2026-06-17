import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:temu_disabilitas/providers/auth_provider.dart';
import 'package:temu_disabilitas/providers/forum_provider.dart';
import 'package:temu_disabilitas/utils/validators.dart';
import 'package:temu_disabilitas/widgets/custom_button.dart';
import 'package:temu_disabilitas/widgets/custom_text_field.dart';

class BuatPostingScreen extends StatefulWidget {
  const BuatPostingScreen({super.key});

  @override
  State<BuatPostingScreen> createState() => _BuatPostingScreenState();
}

class _BuatPostingScreenState extends State<BuatPostingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _isiController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _isiController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final userId = context.read<AuthProvider>().currentUser!.id!;
    await context.read<ForumProvider>().createPosting(userId, _isiController.text);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Postingan')),
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
                label: 'Publikasikan',
                isLoading: _submitting,
                onPressed: _submit,
                icon: Icons.publish,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
