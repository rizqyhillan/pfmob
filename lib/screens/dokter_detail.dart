import 'package:flutter/material.dart';
import '../theme/tema_app.dart';
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
              _buildLayanan(context),
              _buildUlasan(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 220,
          width: double.infinity,
          color: AppColors.primaryLight,
          child: const Center(
            child: Text('👩‍⚕️', style: TextStyle(fontSize: 100)),
          ),
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
        Positioned(
          bottom: 16, left: 16,
          child: Row(
            children: const [
              Icon(Icons.star_rounded, color: AppColors.gold, size: 18),
              SizedBox(width: 4),
              Text('4.9', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 14)),
              SizedBox(width: 12),
              Icon(Icons.workspace_premium_outlined, color: Colors.white, size: 16),
              SizedBox(width: 4),
              Text('8+ years', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 13)),
            ],
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
        children: const [
          Text('Dr. Sarah', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textDark)),
          SizedBox(height: 4),
          Text('Veterinary Specialist – Small Animals', style: TextStyle(fontSize: 14, color: AppColors.textLight, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildTentangDokter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.categoryBg1,
          borderRadius: BorderRadius.circular(16),
        ),
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

  Widget _buildLayanan(BuildContext context) {
    final layanan = [
      {
        'icon': Icons.medical_services_outlined,
        'name': 'General Consultation',
        'desc': 'Pemeriksaan rutin & diagnosa',
        'color': const Color(0xFFFF9800),
      },
      {
        'icon': Icons.vaccines_outlined,
        'name': 'Vaccination',
        'desc': 'Proteksi virus lengkap',
        'color': const Color(0xFF4A9B8E),
      },
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Layanan Kami', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textDark)),
              Text('LIHAT SEMUA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.gold, letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Pilih layanan untuk melanjutkan booking', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
          const SizedBox(height: 12),
          ...layanan.map((l) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => KonfirmasiBookingScreen(
                    namaLayanan: l['name'] as String,
                  ),
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.divider),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        color: (l['color'] as Color).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(l['icon'] as IconData, color: l['color'] as Color, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l['name'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                          Text(l['desc'] as String, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textLight),
                  ],
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildUlasan() {
    final ulasan = [
      {'nama': 'Andi Pratama', 'bintang': 5, 'komentar': 'Dr. Sarah sangat sabar menangani kucing saya yang sangat penakut. Penjelasannya sangat jelas dan menenangkan.'},
      {'nama': 'Maya Sari', 'bintang': 4, 'komentar': 'Pelayanan sangat bagus. Klinik bersih dan nyaman. Recomended!'},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ulasan Pengguna', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textDark)),
          const SizedBox(height: 12),
          ...ulasan.map((u) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38, height: 38,
                    decoration: const BoxDecoration(color: AppColors.categoryBg1, shape: BoxShape.circle),
                    child: const Center(child: Text('👤', style: TextStyle(fontSize: 18))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(u['nama'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                            Row(
                              children: List.generate(5, (i) => Icon(
                                i < (u['bintang'] as int) ? Icons.star_rounded : Icons.star_outline_rounded,
                                color: AppColors.gold, size: 14,
                              )),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(u['komentar'] as String, style: const TextStyle(fontSize: 12, color: AppColors.textMedium, height: 1.5)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }
}