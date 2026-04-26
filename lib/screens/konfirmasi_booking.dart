import 'package:flutter/material.dart';
import '../theme/tema_app.dart';
import 'data_pasien.dart';

class KonfirmasiBookingScreen extends StatefulWidget {
  final String namaLayanan;
  const KonfirmasiBookingScreen({super.key, required this.namaLayanan});

  @override
  State<KonfirmasiBookingScreen> createState() => _KonfirmasiBookingScreenState();
}

class _KonfirmasiBookingScreenState extends State<KonfirmasiBookingScreen> {
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
                    _buildProgress(),
                    const SizedBox(height: 20),
                    _buildDetailLayanan(),
                    const SizedBox(height: 24),
                    _buildPilihTanggal(),
                    const SizedBox(height: 24),
                    _buildWaktuKunjungan(),
                  ],
                ),
              ),
            ),
            _buildNextButton(context),
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
          const Text('Konfirmasi Booking', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
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
            Text('Detail Layanan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            Text('LANGKAH 1 DARI 3', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textLight, letterSpacing: 0.5)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: 0.33,
            backgroundColor: AppColors.divider,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailLayanan() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.categoryBg1,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                'assets/images/dokter1.jpg',
                width: 56, height: 56,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Dr. Sarah', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark)),
              const Text('Spesialis Bedah Hewan', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.medical_services_outlined, size: 13, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(widget.namaLayanan, style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPilihTanggal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('Pilih Tanggal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark)),
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
                    Text(_days[i]['day']!, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? Colors.white70 : AppColors.textLight)),
                    const SizedBox(height: 4),
                    Text(_days[i]['date']!, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: selected ? Colors.white : AppColors.textDark)),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildWaktuKunjungan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Waktu Kunjungan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark)),
        const SizedBox(height: 14),
        Row(children: const [Icon(Icons.wb_sunny_outlined, size: 16, color: AppColors.gold), SizedBox(width: 6), Text('PAGI', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textLight, letterSpacing: 1))]),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10, runSpacing: 10,
          children: List.generate(_pagiTimes.length, (i) => _buildTimeChip(_pagiTimes[i], i)),
        ),
        const SizedBox(height: 16),
        Row(children: const [Icon(Icons.cloud_outlined, size: 16, color: Color(0xFF4A9B8E)), SizedBox(width: 6), Text('SIANG & SORE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textLight, letterSpacing: 1))]),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10, runSpacing: 10,
          children: List.generate(_siangTimes.length, (i) => _buildTimeChip(_siangTimes[i], i + _pagiTimes.length)),
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
        child: Text(time, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: selected ? Colors.white : AppColors.textDark)),
      ),
    );
  }

  Widget _buildNextButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, -4))],
      ),
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DataPasienScreen())),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(16)),
          child: const Text('Konfirmasi Booking', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
        ),
      ),
    );
  }
}