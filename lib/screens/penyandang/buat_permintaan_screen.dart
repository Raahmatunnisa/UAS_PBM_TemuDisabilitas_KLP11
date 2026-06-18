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

  static const _primaryColor = Color(0xFF0F6E56);
  static const _primaryLight = Color(0xFFE1F5EE);

  // Icon per jenis bantuan
  IconData _iconForJenis(String jenis) {
    if (jenis.contains('Publik')) return Icons.account_balance_rounded;
    if (jenis.contains('Pendidikan')) return Icons.school_rounded;
    if (jenis.contains('Transportasi')) return Icons.directions_car_rounded;
    if (jenis.contains('Medis') || jenis.contains('Kesehatan'))
      return Icons.local_hospital_rounded;
    return Icons.volunteer_activism_rounded;
  }

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
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: _primaryColor,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _tanggal = picked;
        _tanggalDisplayController.text = DateHelper.formatDisplayDate(
          DateHelper.formatDate(picked),
        );
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: _primaryColor,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Tanggal wajib dipilih')));
      return;
    }
    if (_waktu == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Waktu wajib dipilih')));
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
      waktu: DateHelper.formatTime(
        DateTime(2000, 1, 1, _waktu!.hour, _waktu!.minute),
      ),
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
      backgroundColor: const Color(0xFFF8FFFE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Buat Permintaan',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF555555)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _primaryLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: _primaryColor,
                      size: 18,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Isi form berikut untuk mencari relawan pendamping yang sesuai',
                        style: TextStyle(fontSize: 12, color: _primaryColor),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Jenis bantuan
              _sectionLabel('Jenis Bantuan'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFDDDDDD)),
                ),
                child: DropdownButtonFormField<String>(
                  value: _jenisBantuan,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: _primaryColor,
                  ),
                  items: AppConstants.jenisBantuanList.map((e) {
                    return DropdownMenuItem(
                      value: e,
                      child: Row(
                        children: [
                          Icon(
                            _iconForJenis(e),
                            size: 18,
                            color: _primaryColor,
                          ),
                          const SizedBox(width: 10),
                          Text(e, style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _jenisBantuan = v!),
                ),
              ),
              const SizedBox(height: 16),

              // Deskripsi
              _sectionLabel('Deskripsi Kebutuhan'),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _deskripsiController,
                label: 'Jelaskan kebutuhan pendampingan Anda...',
                maxLines: 4,
                validator: (v) => Validators.validateRequired(v, 'Deskripsi'),
              ),
              const SizedBox(height: 16),

              // Tanggal & Waktu
              _sectionLabel('Jadwal Kegiatan'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _tanggalDisplayController,
                      label: 'Tanggal',
                      readOnly: true,
                      onTap: _pickDate,
                      prefixIcon: const Icon(
                        Icons.calendar_today_rounded,
                        color: _primaryColor,
                        size: 18,
                      ),
                      validator: (_) =>
                          _tanggal == null ? 'Wajib dipilih' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _waktuDisplayController,
                      label: 'Waktu',
                      readOnly: true,
                      onTap: _pickTime,
                      prefixIcon: const Icon(
                        Icons.access_time_rounded,
                        color: _primaryColor,
                        size: 18,
                      ),
                      validator: (_) => _waktu == null ? 'Wajib dipilih' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Lokasi
              _sectionLabel('Lokasi Kegiatan'),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _lokasiController,
                label: 'Masukkan lokasi kegiatan',
                prefixIcon: const Icon(
                  Icons.location_on_rounded,
                  color: _primaryColor,
                  size: 18,
                ),
                validator: (v) => Validators.validateRequired(v, 'Lokasi'),
              ),
              const SizedBox(height: 28),

              // Submit button
              CustomButton(
                label: 'Cari Relawan Sekarang',
                isLoading: _submitting,
                onPressed: _submit,
                icon: Icons.search_rounded,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A1A1A),
      ),
    );
  }
}
