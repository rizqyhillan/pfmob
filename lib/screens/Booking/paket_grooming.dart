import 'package:flutter/material.dart';
import '../../theme/tema_app.dart';
import 'konfirmasi_grooming.dart';

class PaketGroomingScreen extends StatelessWidget {
  const PaketGroomingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  children: [
                    _buildPaketCard(
                      context,
                      paket: 'Basic',
                      harga: 'Rp 50.000',
                      deskripsi: 'Mandi + pengeringan bulu',
                      fasilitas: ['Mandi dengan shampoo', 'Pengeringan bulu', 'Penyisiran bulu'],
                      warna: const Color(0xFF4A9B8E),
                      bgColor: const Color(0xFFE0F5F2),
                    ),
                    const SizedBox(height: 16),
                    _buildPaketCard(
                      context,
                      paket: 'Reguler',
                      harga: 'Rp 100.000',
                      deskripsi: 'Basic + potong kuku & telinga',
                      fasilitas: ['Semua layanan Basic', 'Potong kuku', 'Bersihkan telinga', 'Parfum hewan'],
                      warna: const Color(0xFF2196F3),
                      bgColor: const Color(0xFFE3F2FD),
                      isFavorit: true,
                    ),
                    const SizedBox(height: 16),
                    _buildPaketCard(
                      context,
                      paket: 'Premium',
                      harga: 'Rp 180.000',
                      deskripsi: 'Reguler + styling & spa',
                      fasilitas: ['Semua layanan Reguler', 'Styling rambut', 'Spa & pijat', 'Bandana/aksesoris'],
                      warna: const Color(0xFFFF9800),
                      bgColor: const Color(0xFFFFF3E0),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: AppColors.categoryBg1,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Pilih Paket Grooming',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textDark),
          ),
          const SizedBox(height: 4),
          const Text(
            'Pilih paket yang sesuai untuk anabul kamu',
            style: TextStyle(fontSize: 13, color: AppColors.textLight),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPaketCard(
    BuildContext context, {
    required String paket,
    required String harga,
    required String deskripsi,
    required List<String> fasilitas,
    required Color warna,
    required Color bgColor,
    bool isFavorit = false,
  }) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => KonfirmasiGroomingScreen(namaPaket: paket, harga: harga),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isFavorit ? warna : Colors.transparent, width: 2),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Paket $paket',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: warna),
                            ),
                            if (isFavorit) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: warna,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(deskripsi, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
                      ],
                    ),
                  ],
                ),
                Text(
                  harga,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: warna),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(),
            const SizedBox(height: 10),
            ...fasilitas.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: warna, size: 16),
                  const SizedBox(width: 8),
                  Text(f, style: const TextStyle(fontSize: 13, color: AppColors.textMedium)),
                ],
              ),
            )),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: warna,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Pilih Paket $paket',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}