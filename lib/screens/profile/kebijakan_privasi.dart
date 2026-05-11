import 'package:flutter/material.dart';

import '../../theme/tema_app.dart';

class KebijakanPrivasiPage extends StatelessWidget {
  const KebijakanPrivasiPage({super.key});

  Widget _section({
    required IconData icon,
    required String title,
    required String body,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primaryLight,
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Kebijakan Privasi',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.privacy_tip_outlined,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'PawPet menjaga data akun, hewan, rekam medis, dan transaksi pengguna agar tetap aman.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textMedium,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          _section(
            icon: Icons.person_outline_rounded,
            title: 'Data Pengguna',
            body:
                'Kami menyimpan data seperti nama, email, nomor telepon, dan alamat untuk kebutuhan akun dan layanan.',
          ),
          _section(
            icon: Icons.pets_rounded,
            title: 'Data Hewan Peliharaan',
            body:
                'Data hewan seperti nama, jenis, ras, umur, dan catatan digunakan untuk membantu layanan klinik dan rekam medis.',
          ),
          _section(
            icon: Icons.medical_information_outlined,
            title: 'Rekam Medis',
            body:
                'Rekam medis hanya digunakan untuk kebutuhan pemeriksaan, riwayat kesehatan, dan layanan dokter.',
          ),
          _section(
            icon: Icons.receipt_long_outlined,
            title: 'Transaksi',
            body:
                'Riwayat transaksi digunakan untuk menampilkan laporan pembelian produk, layanan, dan pembayaran pengguna.',
          ),
          _section(
            icon: Icons.lock_outline_rounded,
            title: 'Keamanan Akun',
            body:
                'Password disimpan dalam bentuk terenkripsi. Token login digunakan agar pengguna dapat mengakses fitur yang membutuhkan autentikasi.',
          ),
          _section(
            icon: Icons.share_outlined,
            title: 'Pembagian Data',
            body:
                'Data pengguna tidak dibagikan ke pihak luar tanpa alasan layanan yang jelas atau persetujuan pengguna.',
          ),

          const SizedBox(height: 10),
          const Text(
            'Terakhir diperbarui: 2026',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textLight,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}