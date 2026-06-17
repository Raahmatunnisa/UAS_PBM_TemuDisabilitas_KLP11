import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:temu_disabilitas/providers/auth_provider.dart';
import 'package:temu_disabilitas/providers/user_provider.dart';
import 'package:temu_disabilitas/utils/validators.dart';
import 'package:temu_disabilitas/widgets/custom_button.dart';
import 'package:temu_disabilitas/widgets/custom_text_field.dart';

class EditProfilScreen extends StatefulWidget {
  const EditProfilScreen({super.key});

  @override
  State<EditProfilScreen> createState() => _EditProfilScreenState();
}

class _EditProfilScreenState extends State<EditProfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _teleponController = TextEditingController();
  final _kebutuhanController = TextEditingController();
  final _keahlianController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _jadwalController = TextEditingController();
  final _picker = ImagePicker();
  File? _newFoto;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser!;
    _namaController.text = user.nama;
    _teleponController.text = user.telepon;
    _kebutuhanController.text = user.kebutuhanKhusus ?? '';
    _keahlianController.text = user.keahlian ?? '';
    _deskripsiController.text = user.deskripsiRelawan ?? '';
    _jadwalController.text = user.jadwalKetersediaan ?? '';
  }

  @override
  void dispose() {
    _namaController.dispose();
    _teleponController.dispose();
    _kebutuhanController.dispose();
    _keahlianController.dispose();
    _deskripsiController.dispose();
    _jadwalController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 800);
    if (picked != null) setState(() => _newFoto = File(picked.path));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    final auth = context.read<AuthProvider>();
    final userProvider = context.read<UserProvider>();
    var user = auth.currentUser!;

    if (_newFoto != null) {
      await userProvider.updateProfileImage(_newFoto!, user.id!);
      user = userProvider.user ?? user;
    }

    final updated = user.copyWith(
      nama: _namaController.text.trim(),
      telepon: _teleponController.text.trim(),
      kebutuhanKhusus: auth.isPenyandang ? _kebutuhanController.text.trim() : user.kebutuhanKhusus,
      keahlian: auth.isRelawan ? _keahlianController.text.trim() : user.keahlian,
      deskripsiRelawan: auth.isRelawan ? _deskripsiController.text.trim() : user.deskripsiRelawan,
      jadwalKetersediaan: auth.isRelawan ? _jadwalController.text.trim() : user.jadwalKetersediaan,
    );

    final success = await userProvider.updateProfile(updated);
    if (success) {
      auth.updateCurrentUser(updated);
    }

    if (mounted) {
      setState(() => _submitting = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  backgroundImage: _newFoto != null
                      ? FileImage(_newFoto!)
                      : (user.fotoProfil != null && user.fotoProfil!.isNotEmpty
                          ? FileImage(File(user.fotoProfil!))
                          : null),
                  child: _newFoto == null && (user.fotoProfil == null || user.fotoProfil!.isEmpty)
                      ? Icon(Icons.add_a_photo, size: 40, color: theme.colorScheme.primary)
                      : null,
                ),
              ),
              const SizedBox(height: 8),
              const Text('Ketuk untuk ganti foto'),
              const SizedBox(height: 24),
              CustomTextField(
                controller: _namaController,
                label: 'Nama Lengkap',
                validator: (v) => Validators.validateRequired(v, 'Nama'),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _teleponController,
                label: 'Nomor Telepon',
                keyboardType: TextInputType.phone,
                validator: Validators.validatePhone,
              ),
              if (auth.isPenyandang) ...[
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _kebutuhanController,
                  label: 'Kebutuhan Khusus',
                  maxLines: 3,
                  validator: (v) => Validators.validateRequired(v, 'Kebutuhan khusus'),
                ),
              ],
              if (auth.isRelawan) ...[
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _keahlianController,
                  label: 'Keahlian Pendampingan',
                  validator: (v) => Validators.validateRequired(v, 'Keahlian'),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _deskripsiController,
                  label: 'Deskripsi Singkat',
                  maxLines: 3,
                  validator: (v) => Validators.validateRequired(v, 'Deskripsi'),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _jadwalController,
                  label: 'Jadwal Ketersediaan',
                  validator: (v) => Validators.validateRequired(v, 'Jadwal ketersediaan'),
                ),
              ],
              const SizedBox(height: 24),
              CustomButton(
                label: 'Simpan',
                isLoading: _submitting,
                onPressed: _save,
                icon: Icons.save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
