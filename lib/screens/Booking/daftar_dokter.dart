import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/tema_app.dart';
import 'dokter_detail.dart';

class DaftarDokterScreen extends StatefulWidget {
  const DaftarDokterScreen({super.key});

  @override
  State<DaftarDokterScreen> createState() => _DaftarDokterScreenState();
}

class _DaftarDokterScreenState extends State<DaftarDokterScreen> {
  List<Doctor> _doctors = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final doctors = await ApiService.getDoctors();
      if (!mounted) return;
      setState(() {
        _doctors = doctors;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

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
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(color: AppColors.categoryBg1, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Pilih Dokter Hewan', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textDark)),
            const SizedBox(height: 4),
            const Text('Pilih Dokter yang tersedia', style: TextStyle(fontSize: 13, color: AppColors.textLight)),
          ],
        ),
      );

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return _message('⚠️', _error!, 'Coba Lagi', _loadDoctors);
    if (_doctors.isEmpty) return _message('👨‍⚕️', 'Belum ada dokter aktif', 'Muat ulang', _loadDoctors);
    return RefreshIndicator(
      onRefresh: _loadDoctors,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        itemCount: _doctors.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) => _buildDokterCard(context, _doctors[i]),
      ),
    );
  }

  Widget _message(String icon, String title, String action, VoidCallback onAction) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textMedium, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onAction, child: Text(action)),
          ],
        ),
      );

  Widget _buildDokterCard(BuildContext context, Doctor dokter) => GestureDetector(
        onTap: dokter.tersedia ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => DokterDetailScreen(doctor: dokter))) : null,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.divider)),
          child: Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.categoryBg3),
                child: ClipOval(
                  child: _isValidUrl(dokter.fotoUrl)
                      ? Image.network(
                          _getBustedUrl(dokter.fotoUrl!),
                          width: 62,
                          height: 62,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => Image.asset(
                            'assets/images/pet-dokter.png',
                            width: 62,
                            height: 62,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Image.asset(
                          'assets/images/pet-dokter.png',
                          width: 62,
                          height: 62,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dokter.nama, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                    const SizedBox(height: 3),
                    Text(dokter.spesialis, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 16, color: AppColors.gold),
                        const SizedBox(width: 4),
                        Text(dokter.rating.toStringAsFixed(1), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                        const SizedBox(width: 10),
                        Text(dokter.pengalaman, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
            ],
          ),
        ),
      );

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
