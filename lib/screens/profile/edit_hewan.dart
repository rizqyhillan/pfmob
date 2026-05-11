import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../theme/tema_app.dart';

class EditHewanScreen extends StatefulWidget {
  final int id;
  final String nama;
  final String jenis;
  final String ras;
  final String umur;
  final String kelamin;
  final String foto;
  final Color warna;
  final String tentang;

  const EditHewanScreen({
    super.key,
    required this.id,
    required this.nama,
    required this.jenis,
    required this.ras,
    required this.umur,
    required this.kelamin,
    required this.foto,
    required this.warna,
    required this.tentang,
  });

  @override
  State<EditHewanScreen> createState() => _EditHewanScreenState();
}

class _EditHewanScreenState extends State<EditHewanScreen> {
  final _namaController = TextEditingController();
  final _rasController = TextEditingController();
  final _umurController = TextEditingController();
  final _beratController = TextEditingController();
  final _catatanController = TextEditingController();

  final List<String> _jenisHewan = ['Kucing', 'Anjing', 'Kelinci'];
  final List<String> _kelaminList = ['Jantan', 'Betina'];

  String _selectedJenis = 'Kucing';
  String _selectedKelamin = 'Jantan';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _namaController.text = widget.nama;
    _rasController.text = widget.ras;
    _umurController.text = widget.umur;
    _catatanController.text = widget.tentang;

    if (_jenisHewan.contains(widget.jenis)) {
      _selectedJenis = widget.jenis;
    }

    if (_kelaminList.contains(widget.kelamin)) {
      _selectedKelamin = widget.kelamin;
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _rasController.dispose();
    _umurController.dispose();
    _beratController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _simpanPerubahan() async {
    final nama = _namaController.text.trim();
    final ras = _rasController.text.trim();
    final umur = _umurController.text.trim();
    final berat = _beratController.text.trim();
    final catatan = _catatanController.text.trim();

    if (nama.isEmpty) {
      _showSnack('Nama hewan wajib diisi', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ApiService.updatePet(
        id: widget.id,
        namaHewan: nama,
        jenis: _selectedJenis,
        jenisKelamin: _selectedKelamin,
        ras: ras.isEmpty ? null : ras,
        umur: umur.isEmpty ? null : umur,
        berat: berat.isEmpty ? null : berat,
        catatan: catatan.isEmpty ? null : catatan,
      );

      if (!mounted) return;

      _showSnack('Data hewan berhasil diperbarui', AppColors.accent);

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showSnack(
        e.toString().replaceAll('Exception: ', ''),
        Colors.red,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnack(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _input({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(item),
                ),
              )
              .toList(),
          onChanged: _isLoading ? null : onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Edit Hewan',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.warna,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: ClipOval(
                child: widget.foto.isEmpty
                    ? const Icon(
                        Icons.pets,
                        color: AppColors.primary,
                        size: 42,
                      )
                    : Image.asset(
                        widget.foto,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.pets,
                          color: AppColors.primary,
                          size: 42,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
            _input(
              label: 'Nama Hewan',
              controller: _namaController,
              hint: 'Contoh: Mochi',
            ),
            const SizedBox(height: 16),
            _dropdown(
              label: 'Jenis Hewan',
              value: _selectedJenis,
              items: _jenisHewan,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedJenis = value);
                }
              },
            ),
            const SizedBox(height: 16),
            _input(
              label: 'Ras',
              controller: _rasController,
              hint: 'Contoh: Persia',
            ),
            const SizedBox(height: 16),
            _input(
              label: 'Umur',
              controller: _umurController,
              hint: 'Contoh: 2 tahun',
            ),
            const SizedBox(height: 16),
            _input(
              label: 'Berat',
              controller: _beratController,
              hint: 'Contoh: 4.5',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _dropdown(
              label: 'Jenis Kelamin',
              value: _selectedKelamin,
              items: _kelaminList,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedKelamin = value);
                }
              },
            ),
            const SizedBox(height: 16),
            _input(
              label: 'Catatan',
              controller: _catatanController,
              hint: 'Catatan tambahan',
              maxLines: 4,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _simpanPerubahan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.textLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Simpan Perubahan',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}