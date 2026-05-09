import 'package:flutter/material.dart';
import '../../theme/tema_app.dart';
import 'dokter_detail.dart';

class DaftarDokterScreen extends StatelessWidget {
  const DaftarDokterScreen({super.key});

  final List<Map<String, dynamic>> _dokterList = const [
    {
      'nama': 'Dr. Sarah',
      'spesialis': 'Spesialis Hewan Kecil',
      'rating': '4.9',
      'pengalaman': '8+ tahun',
      'emoji': '👩‍⚕️',
      'foto': 'assets/images/dokter1.jpg', // ← foto Dr. Sarah
      'tersedia': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                itemCount: _dokterList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) => _buildDokterCard(context, _dokterList[i]),
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
            'Pilih Dokter Hewan',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textDark),
          ),
          const SizedBox(height: 4),
          const Text(
            'Pilih dokter terbaik untuk sahabat bulu kamu',
            style: TextStyle(fontSize: 13, color: AppColors.textLight),
          ),
        ],
      ),
    );
  }

  Widget _buildDokterCard(BuildContext context, Map<String, dynamic> dokter) {
    final bool tersedia = dokter['tersedia'] as bool;

    return GestureDetector(
      onTap: tersedia
          ? () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DokterDetailScreen()),
              )
          : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.divider),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Row(
          children: [
            // Foto dokter
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: AppColors.categoryBg1,
                borderRadius: BorderRadius.circular(16),
              ),
              child: dokter['foto'] != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        dokter['foto'] as String,
                        width: 64, height: 64,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Center(
                      child: Text(dokter['emoji'], style: const TextStyle(fontSize: 34)),
                    ),
            ),
            const SizedBox(width: 14),

            // Info dokter
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        dokter['nama'],
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: tersedia ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tersedia ? 'Tersedia' : 'Penuh',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: tersedia ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dokter['spesialis'],
                    style: const TextStyle(fontSize: 12, color: AppColors.textLight),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: AppColors.gold, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        dokter['rating'],
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.workspace_premium_outlined, color: AppColors.primary, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        dokter['pengalaman'],
                        style: const TextStyle(fontSize: 12, color: AppColors.textMedium),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}