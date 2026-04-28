import 'package:flutter/material.dart';
import '../../theme/tema_app.dart';
import 'konfirmasi_penitipan.dart';

class PaketPenitipanScreen extends StatelessWidget {
  const PaketPenitipanScreen({super.key});

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
                      paket: 'Basic Boarding',
                      harga: 'Rp 50.000',
                      hargaPerHari: 50000,
                      deskripsi: 'Perawatan dasar dengan kandang standar',
                      fasilitas: ['Kandang standar', 'Makan 2x sehari', 'Minum tersedia', 'Pemantauan harian'],
                      warna: const Color(0xFF4A9B8E),
                      bgColor: const Color(0xFFE0F5F2),
                    ),
                    const SizedBox(height: 16),
                    _buildPaketCard(
                      context,
                      paket: 'Regular Boarding',
                      harga: 'Rp 100.000',
                      hargaPerHari: 100000,
                      deskripsi: 'Lebih nyaman dengan perawatan rutin',
                      fasilitas: ['Kandang lebih luas', 'Makan 3x sehari', 'Bermain 1x sehari', 'Laporan harian ke owner'],
                      warna: const Color(0xFFFF9800),
                      bgColor: const Color(0xFFFFF3E0),
                      isFavorit: true,
                    ),
                    const SizedBox(height: 16),
                    _buildPaketCard(
                      context,
                      paket: 'Premium Boarding',
                      harga: 'Rp 150.000',
                      hargaPerHari: 150000,
                      deskripsi: 'Perawatan terbaik dengan fasilitas lengkap',
                      fasilitas: ['Kamar pribadi ber-AC', 'Makan premium 3x', 'Bermain & grooming', 'Foto update tiap hari'],
                      warna: const Color(0xFF7C4DFF),
                      bgColor: const Color(0xFFEDE7F6),
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
            'Pilih Paket Penitipan',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textDark),
          ),
          const SizedBox(height: 4),
          const Text(
            'Pilih paket penitipan terbaik untuk anabul kamu',
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
    required int hargaPerHari,
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
          builder: (_) => KonfirmasiPenitipanScreen(
            namaPaket: paket,
            harga: harga,
            hargaPerHari: hargaPerHari,
          ),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          paket,
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
                            child: const Text(
                              'TERLARIS',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(deskripsi, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      harga,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: warna),
                    ),
                    const Text(
                      '/ malam',
                      style: TextStyle(fontSize: 11, color: AppColors.textLight),
                    ),
                  ],
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
                'Pilih $paket',
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