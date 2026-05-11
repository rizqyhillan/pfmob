import 'package:flutter/material.dart';
import '../../theme/tema_app.dart';
import 'edit_hewan.dart';
import '../../services/api_service.dart';

class DetailPetScreen extends StatelessWidget {
  final int id;
  final String nama;
  final String jenis;
  final String ras;
  final String umur;
  final String kelamin;
  final String foto;
  final Color warna;
  final String tentang;

  const DetailPetScreen({
    super.key,
    required this.id,
    required this.nama,
    required this.jenis,
    required this.ras,
    required this.umur,
    required this.kelamin,
    required this.foto,
    required this.warna,
    this.tentang = '',
  });

  Future<void> _hapusHewan(BuildContext context) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Text(
        'Hapus Hewan?',
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
      content: Text(
        'Data $nama akan dihapus dari daftar hewan peliharaanmu.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          child: const Text(
            'Hapus',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    ),
  );

  if (confirm != true) return;

  try {
    await ApiService.deletePet(id);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$nama berhasil dihapus'),
        backgroundColor: AppColors.accent,
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pop(context, true);
  } catch (e) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.toString().replaceAll('Exception: ', '')),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: warna,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildFotoSection(context),
                    _buildInfoSection(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFotoSection(BuildContext context) {
    return SizedBox(
      height: 340,
      child: Stack(
        children: [
          // Lingkaran besar di belakang
          Center(
            child: Container(
              width: 260,
              height: 260,
              margin: const EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.3),
              ),
            ),
          ),

          // Foto hewan
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Container(
                width: 220,
                height: 220,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: ClipOval(
                  child: Image.asset(
                    foto,
                    width: 220,
                    height: 220,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.white.withOpacity(0.5),
                      child: const Icon(
                        Icons.pets,
                        color: AppColors.primary,
                        size: 80,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Tombol back
          Positioned(
            top: 16,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16,
                  color: AppColors.textDark,
                ),
              ),
            ),
            
          ),

          // Indikator dot
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == 0 ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == 0
                        ? AppColors.textDark
                        : AppColors.textDark.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nama & icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                nama,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.categoryBg1,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.pets_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Jenis & ras
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 14, color: AppColors.textLight),
              const SizedBox(width: 4),
              Text(
                '$jenis • $ras',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 3 kotak info
          Row(
            children: [
              Expanded(child: _buildInfoBox('Jenis Kelamin', kelamin)),
              const SizedBox(width: 12),
              Expanded(child: _buildInfoBox('Umur', umur)),
              const SizedBox(width: 12),
            ],
          ),
          const SizedBox(height: 24),

          // Tentang
          const Text(
            'Tentang:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            tentang.isEmpty
                ? 'Belum ada informasi tambahan tentang $nama.'
                : tentang,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textMedium,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 32),

          // Tombol Edit — warna primary (orange)
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditHewanScreen(
                  id: id,
                  nama: nama,
                  jenis: jenis,
                  ras: ras,
                  umur: umur,
                  kelamin: kelamin,
                  foto: foto,
                  warna: warna,
                  tentang: tentang,
                ),
              ),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit_outlined, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Edit Data Hewan',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
  child: OutlinedButton.icon(
    onPressed: () => _hapusHewan(context),
    icon: const Icon(Icons.delete_outline_rounded),
    label: const Text(
      'Hapus Hewan',
      style: TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 15,
      ),
    ),
    style: OutlinedButton.styleFrom(
      foregroundColor: Colors.red,
      side: const BorderSide(color: Colors.red),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
    ),
  ),
),
        ],
      ),
    );
  }

  Widget _buildInfoBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.categoryBg1,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}