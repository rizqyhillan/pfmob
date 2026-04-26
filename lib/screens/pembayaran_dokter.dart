import 'package:flutter/material.dart';
import '../theme/tema_app.dart';

class PembayaranDokterScreen extends StatelessWidget {
  final String namaHewan;
  final String keluhan;

  const PembayaranDokterScreen({
    super.key,
    required this.namaHewan,
    required this.keluhan,
  });

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
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProgress(),
                    const SizedBox(height: 24),
                    _buildKonfirmasiPesanan(),
                    const SizedBox(height: 20),
                    _buildPilihanHewan(),
                    const SizedBox(height: 20),
                    _buildKeluhan(),
                  ],
                ),
              ),
            ),
            _buildSelesaiButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(color: AppColors.categoryBg1, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 16),
          const Text('Ringkasan & Pembayaran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
        ],
      ),
    );
  }

  Widget _buildProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('LANGKAH 3 DARI 3', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textLight, letterSpacing: 0.5)),
            Text('100%', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primary)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: 1.0,
            backgroundColor: AppColors.divider,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildKonfirmasiPesanan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Konfirmasi Pesanan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.categoryBg1,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                child: const Center(child: Text('👩‍⚕️', style: TextStyle(fontSize: 28))),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Dr. Sarah', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                  Text('General Check-up & Vaksinasi', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 13, color: AppColors.primary),
                      SizedBox(width: 4),
                      Text('Kamis, 24 Oktober 2024', style: TextStyle(fontSize: 12, color: AppColors.textMedium, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.access_time_outlined, size: 13, color: AppColors.primary),
                      SizedBox(width: 4),
                      Text('14:30 - 15:00 WIB', style: TextStyle(fontSize: 12, color: AppColors.textMedium, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPilihanHewan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pilihan Hewan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(color: AppColors.categoryBg1, shape: BoxShape.circle),
                child: const Center(child: Text('🐱', style: TextStyle(fontSize: 28))),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(namaHewan, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                  const Text('Kucing • 2 Thn', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKeluhan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Keluhan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark)),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Text(
            keluhan.isEmpty ? 'Tidak ada keluhan yang diisi' : keluhan,
            style: const TextStyle(fontSize: 13, color: AppColors.textMedium, height: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildSelesaiButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, -4))],
      ),
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Booking berhasil! 🎉'), backgroundColor: Color(0xFF4A9B8E)),
          );
          Navigator.popUntil(context, (route) => route.isFirst);
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(16)),
          child: const Text('Selesai', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
        ),
      ),
    );
  }
}