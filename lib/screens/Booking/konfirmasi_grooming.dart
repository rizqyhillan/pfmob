import 'package:flutter/material.dart';
import '../../theme/tema_app.dart';
import '../Home/dashboard.dart';

class KonfirmasiGroomingScreen extends StatefulWidget {
  final String namaPaket;
  final String harga;
  const KonfirmasiGroomingScreen({super.key, required this.namaPaket, required this.harga});

  @override
  State<KonfirmasiGroomingScreen> createState() => _KonfirmasiGroomingScreenState();
}

class _KonfirmasiGroomingScreenState extends State<KonfirmasiGroomingScreen> {
  int _selectedDay = 0;
  int _selectedTime = 1;
  int _selectedHewan = 0;

  final List<Map<String, String>> _hewan = [
    {'type': 'hewan', 'nama': 'Buddy', 'emoji': '🐶'},
    {'type': 'hewan', 'nama': 'Mittens', 'emoji': '🐱'},
    {'type': 'hewan', 'nama': 'Charlie', 'emoji': '🐰'},
  ];

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
                    const SizedBox(height: 20),
                    _buildDetailPaket(),
                    const SizedBox(height: 24),
                    _buildPilihTanggal(),
                    const SizedBox(height: 24),
                    _buildWaktuKunjungan(),
                    const SizedBox(height: 24),
                    _buildEstimasiBiaya(),
                    const SizedBox(height: 8),
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

  Widget _buildDetailPaket() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.categoryBg1, borderRadius: BorderRadius.circular(16)),
          child: Row(
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                child: const Center(child: Text('✂️', style: TextStyle(fontSize: 28))),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Grooming', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                  Text('Paket ${widget.namaPaket}', style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.payments_outlined, size: 13, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(widget.harga, style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text('Pilih Peliharaan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark)),
        const SizedBox(height: 14),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _hewan.length,
            itemBuilder: (context, i) {
              final h = _hewan[i];
              final selected = _selectedHewan == i;
              return GestureDetector(
                onTap: () => setState(() => _selectedHewan = i),
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Column(
                    children: [
                      Container(
                        width: 68, height: 68,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                            color: selected ? AppColors.primary : AppColors.divider,
                            width: selected ? 3 : 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(h['emoji']!, style: const TextStyle(fontSize: 36)),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        h['nama']!,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: selected ? AppColors.primary : AppColors.textDark,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
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

  Widget _buildEstimasiBiaya() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Paket', style: TextStyle(fontSize: 14, color: AppColors.textLight)),
              Text('Grooming ${widget.namaPaket}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Harga', style: TextStyle(fontSize: 14, color: AppColors.textLight)),
              Text(widget.harga, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider()),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('ESTIMASI BIAYA', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textDark, letterSpacing: 0.5)),
              Text(
                widget.harga,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F5F2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline_rounded, size: 14, color: AppColors.primary),
                SizedBox(width: 6),
                Text('Pembayaran dilakukan di tempat', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
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
        onTap: () => _showRingkasanPopup(context),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(16)),
          child: const Text('Lanjutkan', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
        ),
      ),
    );
  }

  void _showRingkasanPopup(BuildContext context) {
    final hewan = _hewan[_selectedHewan];
    final hari = _days[_selectedDay];
    final waktu = _selectedTime < _pagiTimes.length
        ? _pagiTimes[_selectedTime]
        : _siangTimes[_selectedTime - _pagiTimes.length];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Konfirmasi Booking', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
            const Text('Pastikan detail booking kamu sudah benar', style: TextStyle(fontSize: 13, color: AppColors.textLight)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.categoryBg1, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  _buildPopupRow(Icons.content_cut_outlined, 'Paket', 'Grooming ${widget.namaPaket}', AppColors.primary),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1)),
                  _buildPopupRow(Icons.pets_outlined, 'Peliharaan', hewan['nama']!, AppColors.accent),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1)),
                  _buildPopupRow(Icons.calendar_today_outlined, 'Tanggal', '${hari['day']}, ${hari['date']} Oktober 2025', const Color(0xFF7C4DFF)),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1)),
                  _buildPopupRow(Icons.access_time_outlined, 'Waktu', '$waktu WIB', const Color(0xFFFF9800)),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1)),
                  _buildPopupRow(Icons.payments_outlined, 'Total', widget.harga, const Color(0xFF4CAF50)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(color: AppColors.categoryBg1, borderRadius: BorderRadius.circular(14)),
                      child: const Text('Ubah', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _showSuksesPopup(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(14)),
                      child: const Text('Ya, Konfirmasi!', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSuksesPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      isDismissible: false,
      enableDrag: false,
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
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🎉', style: TextStyle(fontSize: 40)),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Booking Berhasil!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark),
            ),
            const SizedBox(height: 8),
            const Text(
              'Booking grooming kamu sudah dikonfirmasi.\nSampai jumpa di hari H ya!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textLight, height: 1.5),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const DashboardScreen()),
                  (route) => false,
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
                  'Kembali ke Beranda',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopupRow(IconData icon, String label, String value, Color iconColor) {
    return Row(
      children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textLight, fontWeight: FontWeight.w600)),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          ],
        ),
      ],
    );
  }
}