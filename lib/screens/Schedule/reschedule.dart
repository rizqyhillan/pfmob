import 'package:flutter/material.dart';
import '../../theme/tema_app.dart';

class RescheduleScreen extends StatefulWidget {
  final String judulLayanan;
  final String namaHewan;
  final String tanggalLama;
  final String waktuLama;

  const RescheduleScreen({
    super.key,
    required this.judulLayanan,
    required this.namaHewan,
    required this.tanggalLama,
    required this.waktuLama,
  });

  @override
  State<RescheduleScreen> createState() => _RescheduleScreenState();
}

class _RescheduleScreenState extends State<RescheduleScreen> {
  int _selectedDay = 0;
  int _selectedTime = 1;

  final List<Map<String, String>> _days = [
    {'day': 'Sen', 'date': '12'},
    {'day': 'Sel', 'date': '13'},
    {'day': 'Rab', 'date': '14'},
    {'day': 'Kam', 'date': '15'},
    {'day': 'Jum', 'date': '16'},
  ];

  final List<String> _pagiTimes = ['09:00', '10:00', '11:00'];
  final List<String> _siangTimes = ['13:00', '14:00', '15:00', '16:00'];

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
                    _buildInfoLama(),
                    const SizedBox(height: 24),
                    _buildPilihTanggalBaru(),
                    const SizedBox(height: 24),
                    _buildWaktuBaru(),
                  ],
                ),
              ),
            ),
            _buildSimpanButton(context),
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
              decoration: BoxDecoration(
                color: AppColors.categoryBg1,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Reschedule',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoLama() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jadwal Saat Ini',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Column(
            children: [
              // Layanan
              Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.categoryBg1,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.medical_services_outlined, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.judulLayanan,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark),
                      ),
                      Text(
                        widget.namaHewan,
                        style: const TextStyle(fontSize: 12, color: AppColors.textLight),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              // Tanggal & waktu lama
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textLight),
                  const SizedBox(width: 6),
                  Text(
                    widget.tanggalLama,
                    style: const TextStyle(fontSize: 13, color: AppColors.textMedium, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.access_time_outlined, size: 14, color: AppColors.textLight),
                  const SizedBox(width: 6),
                  Text(
                    widget.waktuLama,
                    style: const TextStyle(fontSize: 13, color: AppColors.textMedium, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Panah ke bawah
        Center(
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_downward_rounded, color: AppColors.primary, size: 20),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Jadwal Baru',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark),
        ),
      ],
    );
  }

  Widget _buildPilihTanggalBaru() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('Pilih Tanggal', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            Text('Oktober 2025', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.gold)),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_days.length, (i) {
            final selected = _selectedDay == i;
            return GestureDetector(
              onTap: () => setState(() => _selectedDay = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 56, height: 68,
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: selected ? AppColors.primary : AppColors.divider),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _days[i]['day']!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white70 : AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _days[i]['date']!,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: selected ? Colors.white : AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildWaktuBaru() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pilih Waktu', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        const SizedBox(height: 14),
        Row(
          children: const [
            Icon(Icons.wb_sunny_outlined, size: 16, color: AppColors.gold),
            SizedBox(width: 6),
            Text('PAGI', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textLight, letterSpacing: 1)),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10, runSpacing: 10,
          children: List.generate(_pagiTimes.length, (i) => _buildTimeChip(_pagiTimes[i], i)),
        ),
        const SizedBox(height: 16),
        Row(
          children: const [
            Icon(Icons.cloud_outlined, size: 16, color: Color(0xFF4A9B8E)),
            SizedBox(width: 6),
            Text('SIANG & SORE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textLight, letterSpacing: 1)),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10, runSpacing: 10,
          children: List.generate(
            _siangTimes.length,
            (i) => _buildTimeChip(_siangTimes[i], i + _pagiTimes.length),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeChip(String time, int index) {
    final selected = _selectedTime == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTime = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppColors.primary : AppColors.divider),
        ),
        child: Text(
          time,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : AppColors.textDark,
          ),
        ),
      ),
    );
  }

  Widget _buildSimpanButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, -4))],
      ),
      child: GestureDetector(
        onTap: () {
          final hari = _days[_selectedDay];
          final waktu = _selectedTime < _pagiTimes.length
              ? _pagiTimes[_selectedTime]
              : _siangTimes[_selectedTime - _pagiTimes.length];

          // Tampilkan konfirmasi
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            builder: (_) => Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    width: 80, height: 80,
                    decoration: const BoxDecoration(color: Color(0xFFE8F5E9), shape: BoxShape.circle),
                    child: const Center(child: Text('✅', style: TextStyle(fontSize: 40))),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Reschedule Berhasil!',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Jadwal baru kamu:\n${hari['day']}, ${hari['date']} Oktober 2025 • $waktu WIB',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: AppColors.textLight, height: 1.5),
                  ),
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context); // tutup bottom sheet
                      Navigator.pop(context); // kembali ke schedule
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'Kembali ke Jadwal',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Text(
            'Simpan Jadwal Baru',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
          ),
        ),
      ),
    );
  }
}