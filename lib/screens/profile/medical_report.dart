import 'package:flutter/material.dart';

import '../../models/medical_record.dart';
class MedicalReportDetailPage extends StatelessWidget {
  final MedicalRecord record;

  const MedicalReportDetailPage({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4EF),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildProgressBar(),
                  const SizedBox(height: 24),
                  _buildDoctorCard(),
                  const SizedBox(height: 24),
                  _buildPetCard(),
                  const SizedBox(height: 24),
                  _buildSection(
                    icon: Icons.search_rounded,
                    iconColor: const Color(0xFF4A90D9),
                    label: 'Diagnosa',
                    content: record.diagnosa,
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    icon: Icons.medical_services_rounded,
                    iconColor: const Color(0xFF4CAF7D),
                    label: 'Tindakan',
                    content: record.tindakan,
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    icon: Icons.medication_rounded,
                    iconColor: const Color(0xFFE8963A),
                    label: 'Resep Obat',
                    content: record.resep,
                  ),
                  if (record.catatan != null &&
                      record.catatan!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildSection(
                      icon: Icons.notes_rounded,
                      iconColor: const Color(0xFF7C6AF7),
                      label: 'Catatan Dokter',
                      content: record.catatan!,
                    ),
                  ],
                  const SizedBox(height: 32),
                  _buildBottomButton(context),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: const Color(0xFFF8F4EF),
      elevation: 0,
      pinned: true,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.arrow_back_ios_new,
              size: 16, color: Color(0xFF2C2C2C)),
        ),
      ),
      title: const Text(
        'Ringkasan & Pembayaran',
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: Color(0xFF2C2C2C),
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'LANGKAH 3 DARI 3',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF9E9E9E),
                letterSpacing: 0.8,
              ),
            ),
            const Text(
              '100%',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFFE8963A),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: 1.0,
            backgroundColor: const Color(0xFFE8E0D8),
            valueColor:
                const AlwaysStoppedAnimation<Color>(Color(0xFFE8963A)),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorCard() {
    final bulan = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final hariNama = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    final tanggalStr =
        '${hariNama[record.tanggal.weekday % 7]}, ${record.tanggal.day} ${bulan[record.tanggal.month]} ${record.tanggal.year}';
    final jamStr =
        '${record.tanggal.hour.toString().padLeft(2, '0')}:${record.tanggal.minute.toString().padLeft(2, '0')} WIB';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Konfirmasi Pesanan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF2C2C2C),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Foto dokter
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F0F8),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: _isValidUrl(record.fotoUrl)
                        ? Image.network(
                            _getBustedUrl(record.fotoUrl!),
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE8963A)),
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) => Image.asset(
                              'assets/images/pet-dokter.png',
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Image.asset(
                            'assets/images/pet-dokter.png',
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.namaDokter,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2C2C2C),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        record.spesialisasiDokter,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF9E9E9E),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded,
                              size: 13, color: Color(0xFF9E9E9E)),
                          const SizedBox(width: 5),
                          Text(
                            tanggalStr,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B6B6B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded,
                              size: 13, color: Color(0xFF9E9E9E)),
                          const SizedBox(width: 5),
                          Text(
                            jamStr,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B6B6B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (record.beratSaatItu != null) ...[
                            const SizedBox(width: 12),
                            const Icon(Icons.monitor_weight_outlined,
                                size: 13, color: Color(0xFF9E9E9E)),
                            const SizedBox(width: 4),
                            Text(
                              '${record.beratSaatItu} kg',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B6B6B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPetCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilihan Hewan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF2C2C2C),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Avatar hewan
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F0E8),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFE8963A).withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  _petEmoji(record.jenisHewan),
                  style: const TextStyle(fontSize: 36),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.namaHewan,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2C2C2C),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${record.jenisHewan} • ${record.umurHewan}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF9E9E9E),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (record.rasHewan != '-') ...[
                  const SizedBox(height: 2),
                  Text(
                    record.rasHewan,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFB0A090),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
            const Spacer(),
            // Pemilik chip
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: const Color(0xFFE8963A).withValues(alpha: 0.3)),
              ),
              child: Text(
                record.namaPemilik,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFE8963A),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 17),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2C2C2C),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEDE8E3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF4A4A4A),
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE8963A),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        child: const Text('Selesai'),
      ),
    );
  }

  String _petEmoji(String jenis) {
    switch (jenis.toLowerCase()) {
      case 'kucing':
        return '🐱';
      case 'anjing':
        return '🐶';
      case 'kelinci':
        return '🐰';
      default:
        return '🐾';
    }
  }

  bool _isValidUrl(String? url) {
    if (url == null) return false;
    final clean = url.trim().toLowerCase();
    if (clean.isEmpty) return false;
    if (clean == 'null') return false;
    if (clean.endsWith('/storage/') || clean.endsWith('/storage')) return false;
    return true;
  }

  String _getBustedUrl(String url) {
    final separator = url.contains('?') ? '&' : '?';
    return '$url${separator}v=${DateTime.now().minute}';
  }
}

