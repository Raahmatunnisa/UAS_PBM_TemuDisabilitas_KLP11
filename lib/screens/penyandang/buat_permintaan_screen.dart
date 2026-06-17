import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:temu_disabilitas/providers/auth_provider.dart';
import 'package:temu_disabilitas/providers/pendampingan_provider.dart';
import 'package:temu_disabilitas/routes/app_routes.dart';
import 'package:temu_disabilitas/utils/constants.dart';
import 'package:temu_disabilitas/utils/date_helper.dart';
import 'package:temu_disabilitas/utils/validators.dart';
import 'package:temu_disabilitas/widgets/custom_button.dart';
import 'package:temu_disabilitas/widgets/custom_text_field.dart';

class BuatPermintaanScreen extends StatefulWidget {
  const BuatPermintaanScreen({super.key});

  @override
  State<BuatPermintaanScreen> createState() => _BuatPermintaanScreenState();
}

class _BuatPermintaanScreenState extends State<BuatPermintaanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _deskripsiController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _tanggalDisplayController = TextEditingController();
  final _waktuDisplayController = TextEditingController();
  String _jenisBantuan = AppConstants.jenisBantuanList.first;
  DateTime? _tanggal;
  TimeOfDay? _waktu;
  bool _submitting = false;

  @override
  void dispose() {
    _deskripsiController.dispose();
    _lokasiController.dispose();
    _tanggalDisplayController.dispose();
    _waktuDisplayController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _tanggal = picked;
        _tanggalDisplayController.text = DateHelper.formatDisplayDate(DateHelper.formatDate(picked));
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _waktu = picked;
        _waktuDisplayController.text = picked.format(context);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_tanggal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanggal wajib dipilih')),
      );
      return;
    }
    if (_waktu == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Waktu wajib dipilih')),
      );
      return;
    }

    setState(() => _submitting = true);
    final user = context.read<AuthProvider>().currentUser!;
    final provider = context.read<PendampinganProvider>();

    final id = await provider.createPermintaan(
      userId: user.id!,
      jenisBantuan: _jenisBantuan,
      deskripsi: _deskripsiController.text,
      tanggal: DateHelper.formatDate(_tanggal!),
      waktu: DateHelper.formatTime(DateTime(2000, 1, 1, _waktu!.hour, _waktu!.minute)),
      lokasi: _lokasiController.text,
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    Navigator.pushReplacementNamed(
      context,
      AppRoutes.cariRelawan,
      arguments: {'pendampinganId': id, 'jenisBantuan': _jenisBantuan},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Permintaan Pendampingan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _jenisBantuan,
                decoration: const InputDecoration(
                  labelText: 'Jenis Bantuan',
                  border: OutlineInputBorder(),
                ),
                items: AppConstants.jenisBantuanList
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _jenisBantuan = v!),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _deskripsiController,
                label: 'Deskripsi Kebutuhan',
                maxLines: 4,
                validator: (v) => Validators.validateRequired(v, 'Deskripsi'),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _tanggalDisplayController,
                label: 'Tanggal',
                readOnly: true,
                onTap: _pickDate,
                prefixIcon: const Icon(Icons.calendar_today),
                validator: (_) => _tanggal == null ? 'Tanggal wajib dipilih' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _waktuDisplayController,
                label: 'Waktu',
                readOnly: true,
                onTap: _pickTime,
                prefixIcon: const Icon(Icons.access_time),
                validator: (_) => _waktu == null ? 'Waktu wajib dipilih' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _lokasiController,
                label: 'Lokasi',
                prefixIcon: const Icon(Icons.location_on),
                validator: (v) => Validators.validateRequired(v, 'Lokasi'),
              ),
              const SizedBox(height: 24),
              CustomButton(
                label: 'Buat Permintaan',
                isLoading: _submitting,
                onPressed: _submit,
                icon: Icons.send,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
