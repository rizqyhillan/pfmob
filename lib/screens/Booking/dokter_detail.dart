import 'package:flutter/material.dart';
import '../../theme/tema_app.dart';
import 'konfirmasi_booking.dart';

class DokterDetailScreen extends StatelessWidget {
  const DokterDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              _buildDokterInfo(),
              _buildTentangDokter(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildPilihDokterButton(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 220,
          width: double.infinity,
          color: AppColors.primaryLight,
          child: Image.asset('assets/images/dokter1.jpg', width: double.infinity, height: 220, fit: BoxFit.cover),
        ),
        Positioned(
          top: 16, left: 16,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDokterInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Dr. Sarah', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textDark)),
          const SizedBox(height: 4),
          const Text('Veterinary Specialist – Small Animals', style: TextStyle(fontSize: 14, color: AppColors.textLight, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          Row(
            children: [
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppColors.categoryBg1, borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: const [
                    Icon(Icons.workspace_premium_outlined, color: AppColors.primary, size: 16),
                    SizedBox(width: 4),
                    Text('8+ years', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTentangDokter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.categoryBg1, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 18),
                SizedBox(width: 8),
                Text('Tentang Dokter', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark)),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Dr. Sarah adalah seorang spesialis hewan kecil yang berdedikasi dengan pengalaman lebih dari 8 tahun. Ia memiliki keahlian khusus dalam dermatologi dan nutrisi hewan, memastikan peliharaan Anda mendapatkan perawatan terbaik dengan pendekatan yang penuh kasih sayang.',
              style: TextStyle(fontSize: 13, color: AppColors.textMedium, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPilihDokterButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, -4))],
      ),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const KonfirmasiBookingScreen(namaLayanan: '')),
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(16)),
          child: const Text('Pilih Dokter', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
        ),
      ),
    );
  }
}