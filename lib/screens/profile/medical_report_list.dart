import 'package:flutter/material.dart';
import '../../theme/tema_app.dart';
import '../../services/api_service.dart';
import 'medical_report.dart';

class MedicalReportPage extends StatefulWidget {
  const MedicalReportPage({super.key});

  @override
  State<MedicalReportPage> createState() => _MedicalReportPageState();
}

class _MedicalReportPageState extends State<MedicalReportPage> {
  late Future<List<MedicalRecord>> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService.getMedicalRecords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F4EF),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                size: 16, color: AppColors.textDark),
          ),
        ),
        title: const Text(
          'Rekam Medis',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textDark),
            onPressed: () => setState(() {
              _future = ApiService.getMedicalRecords();
            }),
          ),
        ],
      ),
      body: FutureBuilder<List<MedicalRecord>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('😵', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 16),
                    const Text('Gagal memuat data',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark)),
                    const SizedBox(height: 6),
                    Text(snapshot.error.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textLight)),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => setState(() {
                        _future = ApiService.getMedicalRecords();
                      }),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }
          final records = snapshot.data ?? [];
          if (records.isEmpty) return _buildEmpty();
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: records.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (ctx, i) => _buildCard(ctx, records[i]),
          );
        },
      ),
    );
  }

  Widget _buildCard(BuildContext context, MedicalRecord record) {
    final bulan = ['','Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
    final tanggalStr = '${record.tanggal.day} ${bulan[record.tanggal.month]} ${record.tanggal.year}';

    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => MedicalReportDetailPage(record: record))),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.divider),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: AppColors.categoryBg1, shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 2),
              ),
              child: Center(child: Text(_petEmoji(record.jenisHewan), style: const TextStyle(fontSize: 26))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(record.namaHewan,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                      Text(tanggalStr,
                          style: const TextStyle(fontSize: 12, color: AppColors.textLight, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text('${record.jenisHewan} • ${record.rasHewan}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textLight, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  Text(record.namaDokter,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMedium)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: AppColors.categoryBg1, borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      record.diagnosa.length > 40 ? '${record.diagnosa.substring(0, 40)}...' : record.diagnosa,
                      style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: AppColors.textLight, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text('📋', style: TextStyle(fontSize: 56)),
          SizedBox(height: 16),
          Text('Belum ada rekam medis',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          SizedBox(height: 6),
          Text('Rekam medis akan muncul\nsetelah kamu melakukan pemeriksaan.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textLight, height: 1.5)),
        ],
      ),
    );
  }

  String _petEmoji(String jenis) {
    switch (jenis.toLowerCase()) {
      case 'kucing': return '🐱';
      case 'anjing': return '🐶';
      case 'kelinci': return '🐰';
      case 'burung': return '🐦';
      case 'hamster': return '🐹';
      case 'ikan': return '🐠';
      default: return '🐾';
    }
  }
}