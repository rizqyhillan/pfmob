import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/tema_app.dart';
import '../../services/api_service.dart';

class TambahHewanScreen extends StatefulWidget {
  const TambahHewanScreen({super.key});

  @override
  State<TambahHewanScreen> createState() => _TambahHewanScreenState();
}

class _TambahHewanScreenState extends State<TambahHewanScreen> {
  int _selectedJenis = 0;
  String _selectedKelamin = 'Jantan';
  DateTime? _tanggalLahir;
  bool _isLoading = false;
  File? _fotoFile;
  final ImagePicker _picker = ImagePicker();

  final List<Map<String, dynamic>> _jenisHewan = [
    {'label': 'Anjing', 'icon': Icons.pets},
    {'label': 'Kucing', 'icon': Icons.pets},
    {'label': 'Burung', 'icon': Icons.flutter_dash},
    {'label': 'Kelinci', 'icon': Icons.cruelty_free},
  ];

  final _namaController = TextEditingController();
  final _rasController = TextEditingController();

  @override
  void dispose() {
    _namaController.dispose();
    _rasController.dispose();
    super.dispose();
  }

  Future<void> _pilihFoto() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
      maxWidth: 1200,
    );

    if (picked == null) return;

    setState(() {
      _fotoFile = File(picked.path);
    });
  }

  Future<void> _pilihTanggal() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2023),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _tanggalLahir = picked);
  }

  String _hitungUmur(DateTime tanggalLahir) {
  final sekarang = DateTime.now();

  int tahun = sekarang.year - tanggalLahir.year;
  int bulan = sekarang.month - tanggalLahir.month;

  if (sekarang.day < tanggalLahir.day) {
    bulan--;
  }

  if (bulan < 0) {
    tahun--;
    bulan += 12;
  }

  if (tahun > 0) {
    return '$tahun tahun';
  }

  if (bulan > 0) {
    return '$bulan bulan';
  }

  return 'Kurang dari 1 bulan';
}

  String _formatTanggal(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')} / ${dt.month.toString().padLeft(2, '0')} / ${dt.year}';
  }

  Future<void> _simpanHewan() async {
  final nama = _namaController.text.trim();
  final ras = _rasController.text.trim();
  final jenis = _jenisHewan[_selectedJenis]['label'] as String;

  if (nama.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Nama hewan wajib diisi!'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
    return;
  }

  setState(() => _isLoading = true);

  try {
  await ApiService.addPet(
    namaHewan: nama,
    jenis: jenis,
    jenisKelamin: _selectedKelamin,
    tanggalLahir: _tanggalLahir == null
        ? null
        : '${_tanggalLahir!.year.toString().padLeft(4, '0')}-${_tanggalLahir!.month.toString().padLeft(2, '0')}-${_tanggalLahir!.day.toString().padLeft(2, '0')}',
    ras: ras.isEmpty ? null : ras,
    umur: _tanggalLahir == null ? null : _hitungUmur(_tanggalLahir!),
    catatan: null,
    fotoFile: _fotoFile,
  );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Hewan berhasil ditambahkan'),
        backgroundColor: AppColors.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );

    Navigator.pop(context, true);
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.toString().replaceAll('Exception: ', '')),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildUnggahFoto(),
                    const SizedBox(height: 32),
                    _buildNamaHewan(),
                    const SizedBox(height: 20),
                    _buildJenisHewan(),
                    const SizedBox(height: 20),
                    _buildRas(),
                    const SizedBox(height: 20),
                    _buildPilihKelamin(),
                    const SizedBox(height: 20),
                    _buildTanggalLahir(),
                    const SizedBox(height: 40),
                    _buildSimpanButton(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header: sama persis gaya my_pets.dart ──────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          // Tombol back – gaya detail_pet.dart
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.categoryBg1,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Tambah Hewan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                'Lengkapi profil hewan peliharaanmu',
                style: TextStyle(fontSize: 12, color: AppColors.textLight),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Upload foto ────────────────────────────────────────────────────────────
  Widget _buildUnggahFoto() {
    return Center(
      child: GestureDetector(
        onTap: _isLoading ? null : _pilihFoto,
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: AppColors.categoryBg1,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: _fotoFile == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.pets_rounded,
                                size: 40,
                                color: AppColors.primary.withOpacity(0.4),
                              ),
                            ],
                          )
                        : Image.file(
                            _fotoFile!,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              _fotoFile == null ? 'Unggah foto hewan' : 'Ganti foto hewan',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textMedium,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Ambil dari galeri',
              style: TextStyle(fontSize: 12, color: AppColors.textLight),
            ),
          ],
        ),
      ),
    );
  }

  // ── Nama ───────────────────────────────────────────────────────────────────
  Widget _buildNamaHewan() {
    return _buildSectionLabel(
      'Nama Hewan',
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: TextField(
          controller: _namaController,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textDark,
            fontWeight: FontWeight.w600,
          ),
          decoration: const InputDecoration(
            hintText: 'Contoh: Milo',
            hintStyle: TextStyle(color: AppColors.textLight, fontSize: 14),
            border: InputBorder.none,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  // ── Jenis hewan ────────────────────────────────────────────────────────────
  Widget _buildJenisHewan() {
    return _buildSectionLabel(
      'Jenis Hewan',
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(_jenisHewan.length, (i) {
            final selected = _selectedJenis == i;
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () => setState(() => _selectedJenis = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected ? AppColors.primary : AppColors.divider,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _jenisHewan[i]['icon'] as IconData,
                        size: 15,
                        color: selected ? Colors.white : AppColors.textMedium,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _jenisHewan[i]['label'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? Colors.white
                              : AppColors.textMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ── Ras ────────────────────────────────────────────────────────────────────
  Widget _buildRas() {
    return _buildSectionLabel(
      'Ras / Breed',
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: TextField(
          controller: _rasController,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textDark,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: 'Contoh: Golden Retriever',
            hintStyle:
                const TextStyle(color: AppColors.textLight, fontSize: 14),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: Icon(Icons.search,
                color: AppColors.textLight.withOpacity(0.6), size: 20),
          ),
        ),
      ),
    );
  }

  // ── Kelamin – radio bullet ─────────────────────────────────────────────────
  Widget _buildPilihKelamin() {
    return _buildSectionLabel(
      'Jenis Kelamin',
      child: Row(
        children: ['Jantan', 'Betina'].map((kelamin) {
          final selected = _selectedKelamin == kelamin;
          return Expanded(
            child: Padding(
              padding:
                  EdgeInsets.only(right: kelamin == 'Jantan' ? 10 : 0),
              child: GestureDetector(
                onTap: () => setState(() => _selectedKelamin = kelamin),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary.withOpacity(0.07)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected
                          ? AppColors.primary
                          : AppColors.divider,
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Radio bullet
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected
                                ? AppColors.primary
                                : AppColors.textLight,
                            width: 2,
                          ),
                        ),
                        child: selected
                            ? Center(
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.primary,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        kelamin,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? AppColors.primary
                              : AppColors.textMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Tanggal lahir ──────────────────────────────────────────────────────────
  Widget _buildTanggalLahir() {
    return _buildSectionLabel(
      'Tanggal Lahir',
      child: GestureDetector(
        onTap: _pilihTanggal,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _tanggalLahir != null
                      ? _formatTanggal(_tanggalLahir!)
                      : 'DD / MM / YYYY',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _tanggalLahir != null
                        ? AppColors.textDark
                        : AppColors.textLight,
                  ),
                ),
              ),
              const Icon(Icons.calendar_today_outlined,
                  size: 16, color: AppColors.textLight),
            ],
          ),
        ),
      ),
    );
  }

  // ── Tombol simpan ──────────────────────────────────────────────────────────
Widget _buildSimpanButton(BuildContext context) {
  return GestureDetector(
    onTap: _isLoading ? null : _simpanHewan,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: _isLoading ? AppColors.textLight : AppColors.primary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_isLoading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          else ...[
            const Text(
              'Simpan Profil',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
          ],
        ],
      ),
    ),
  );
}

  // ── Helper: label section ──────────────────────────────────────────────────
  Widget _buildSectionLabel(String label, {required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}