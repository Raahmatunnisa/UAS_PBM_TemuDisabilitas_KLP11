import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:temu_disabilitas/database/sqlite_helper.dart';
import 'package:temu_disabilitas/providers/auth_provider.dart';
import 'package:temu_disabilitas/routes/app_routes.dart';
import 'package:temu_disabilitas/services/auth_service.dart';
import 'package:temu_disabilitas/utils/constants.dart';
import 'package:temu_disabilitas/utils/validators.dart';
import 'package:temu_disabilitas/widgets/custom_button.dart';
import 'package:temu_disabilitas/widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _teleponController = TextEditingController();
  final _passwordController = TextEditingController();
  final _keahlianController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _jadwalController = TextEditingController();
  String? _jenisDisabilitas;
  final _kebutuhanController = TextEditingController();
  final _imageService = ImageService();
  final _picker = ImagePicker();

  String _selectedRole = AppConstants.rolePenyandang;
  File? _fotoFile;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _teleponController.dispose();
    _passwordController.dispose();
    _keahlianController.dispose();
    _deskripsiController.dispose();
    _jadwalController.dispose();
    _kebutuhanController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 800);
    if (picked != null) {
      setState(() => _fotoFile = File(picked.path));
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    String? fotoPath;

    final success = await auth.register(
      nama: _namaController.text,
      email: _emailController.text,
      telepon: _teleponController.text,
      password: _passwordController.text,
      role: _selectedRole,
      jenisDisabilitas: _selectedRole == AppConstants.rolePenyandang
          ? _jenisDisabilitas
          : null,
      kebutuhanKhusus: _selectedRole == AppConstants.rolePenyandang
          ? _kebutuhanController.text
          : null,
      keahlian: _selectedRole == AppConstants.roleRelawan
          ? _keahlianController.text
          : null,
      deskripsiRelawan: _selectedRole == AppConstants.roleRelawan
          ? _deskripsiController.text
          : null,
      jadwalKetersediaan: _selectedRole == AppConstants.roleRelawan
          ? _jadwalController.text
          : null,
    );

    if (!mounted) return;

    if (success && auth.currentUser != null) {
      if (_fotoFile != null) {
        fotoPath = await _imageService.saveProfileImage(_fotoFile!, auth.currentUser!.id!);
        if (fotoPath != null) {
          final updated = auth.currentUser!.copyWith(fotoProfil: fotoPath);
          await SQLiteHelper.instance.updateUser(updated);
          auth.updateCurrentUser(updated);
        }
      }

      if (!mounted) return;
      if (auth.isPenyandang) {
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.penyandangMain, (_) => false);
      } else {
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.relawanMain, (_) => false);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? 'Registrasi gagal')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);
    final isRelawan = _selectedRole == AppConstants.roleRelawan;

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Akun')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Semantics(
                    button: true,
                    label: 'Pilih foto profil',
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        backgroundImage: _fotoFile != null ? FileImage(_fotoFile!) : null,
                        child: _fotoFile == null
                            ? Icon(Icons.add_a_photo, size: 40, color: theme.colorScheme.primary)
                            : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text('Ketuk untuk pilih foto profil', textAlign: TextAlign.center),
                const SizedBox(height: 24),
                DropdownButtonFormField<String>(
                  initialValue: _selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Daftar Sebagai',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: AppConstants.rolePenyandang,
                      child: Text(AppConstants.rolePenyandang),
                    ),
                    DropdownMenuItem(
                      value: AppConstants.roleRelawan,
                      child: Text(AppConstants.roleRelawan),
                    ),
                  ],
                  onChanged: (v) => setState(() => _selectedRole = v!),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _namaController,
                  label: 'Nama Lengkap',
                  validator: (v) => Validators.validateRequired(v, 'Nama'),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _teleponController,
                  label: 'Nomor Telepon',
                  keyboardType: TextInputType.phone,
                  validator: Validators.validatePhone,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: Validators.validatePassword,
                ),
                if (!isRelawan) ...[
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Jenis Disabilitas',
                      border: OutlineInputBorder(),
                    ),
                    items: AppConstants.jenisDisabilitasList
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => _jenisDisabilitas = v),
                    validator: (v) => v == null ? 'Jenis disabilitas wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _kebutuhanController,
                    label: 'Kebutuhan Khusus',
                    maxLines: 2,
                    validator: (v) => Validators.validateRequired(v, 'Kebutuhan khusus'),
                  ),
                ],
                if (isRelawan) ...[
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _keahlianController,
                    label: 'Keahlian Pendampingan',
                    hint: 'Contoh: Aktivitas Sehari-hari, Transportasi',
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
                    hint: 'Contoh: Senin-Jumat, 08:00-17:00',
                    validator: (v) => Validators.validateRequired(v, 'Jadwal ketersediaan'),
                  ),
                ],
                const SizedBox(height: 24),
                CustomButton(
                  label: 'Daftar',
                  isLoading: auth.isLoading,
                  onPressed: _register,
                  icon: Icons.person_add,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
