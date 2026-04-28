import 'package:flutter/material.dart';
import '../../theme/tema_app.dart';
import '../Home/dashboard.dart';

class KonfirmasiPenitipanScreen extends StatefulWidget {
  final String namaPaket;
  final String harga;
  final int hargaPerHari;

  const KonfirmasiPenitipanScreen({
    super.key,
    required this.namaPaket,
    required this.harga,
    required this.hargaPerHari,
  });

  @override
  State<KonfirmasiPenitipanScreen> createState() => _KonfirmasiPenitipanScreenState();
}

class _KonfirmasiPenitipanScreenState extends State<KonfirmasiPenitipanScreen> {
  int _selectedHewan = 0;
  DateTime _checkIn = DateTime(2025, 10, 24);
  DateTime _checkOut = DateTime(2025, 10, 27);
  final TextEditingController _catatanController = TextEditingController();

  final List<Map<String, String>> _hewan = [
    {'nama': 'Buddy', 'emoji': '🐶'},
    {'nama': 'Mittens', 'emoji': '🐱'},
    {'nama': 'Charlie', 'emoji': '🐰'},
  ];

  int get _durasi => _checkOut.difference(_checkIn).inDays;
  int get _totalHarga => _durasi * widget.hargaPerHari;

  String _formatTanggal(DateTime dt) {
    const bulan = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${dt.day} ${bulan[dt.month - 1]} ${dt.year}';
  }

  String _formatHarga(int harga) {
    return harga.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }

  Future<void> _pilihTanggal(BuildContext context, bool isCheckIn) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isCheckIn ? _checkIn : _checkOut,
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkIn = picked;
          if (_checkOut.isBefore(_checkIn.add(const Duration(days: 1)))) {
            _checkOut = _checkIn.add(const Duration(days: 1));
          }
        } else {
          if (picked.isAfter(_checkIn)) {
            _checkOut = picked;
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

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
                    const SizedBox(height: 8),
                    _buildDetailPaket(),
                    const SizedBox(height: 24),
                    _buildPilihHewan(),
                    const SizedBox(height: 24),
                    _buildTanggal(context),
                    const SizedBox(height: 24),
                    _buildCatatan(),
                    const SizedBox(height: 24),
                    _buildEstimasiTotal(),
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
          const Text('Konfirmasi Penitipan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
        ],
      ),
    );
  }

  Widget _buildDetailPaket() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.categoryBg1, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: const Center(child: Text('🏠', style: TextStyle(fontSize: 28))),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Penitipan (Boarding)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark)),
              Text(widget.namaPaket, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.payments_outlined, size: 13, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text('${widget.harga} / malam', style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPilihHewan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                        child: Center(child: Text(h['emoji']!, style: const TextStyle(fontSize: 36))),
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

  Widget _buildTanggal(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tanggal Penitipan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark)),
        const SizedBox(height: 14),
        Row(
          children: [
            // Check-in
            Expanded(
              child: GestureDetector(
                onTap: () => _pilihTanggal(context, true),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.primary, width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('CHECK-IN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textLight, letterSpacing: 1)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text(
                            _formatTanggal(_checkIn),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Check-out
            Expanded(
              child: GestureDetector(
                onTap: () => _pilihTanggal(context, false),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.primary, width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('CHECK-OUT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textLight, letterSpacing: 1)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text(
                            _formatTanggal(_checkOut),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCatatan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Catatan Kebutuhan Khusus', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark)),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.divider),
          ),
          child: TextField(
            controller: _catatanController,
            maxLines: 4,
            style: const TextStyle(fontSize: 13, color: AppColors.textDark),
            decoration: const InputDecoration(
              hintText: 'Contoh: Alergi makanan ayam, butuh vitamin jam 8 malam...',
              hintStyle: TextStyle(color: AppColors.textLight, fontSize: 13),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEstimasiTotal() {
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
              const Text('Durasi Penitipan', style: TextStyle(fontSize: 14, color: AppColors.textLight)),
              Text('$_durasi Hari', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Harga / Hari', style: TextStyle(fontSize: 14, color: AppColors.textLight)),
              Text('Rp ${_formatHarga(widget.hargaPerHari)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider()),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('ESTIMASI TOTAL', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textDark, letterSpacing: 0.5)),
              Text(
                'Rp ${_formatHarga(_totalHarga)}',
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
        onTap: () => _showKonfirmasiPopup(context),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(16)),
          child: const Text('Booking Sekarang', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
        ),
      ),
    );
  }

  void _showKonfirmasiPopup(BuildContext context) {
    final hewan = _hewan[_selectedHewan];

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
            const Text('Pastikan detail penitipan kamu sudah benar', style: TextStyle(fontSize: 13, color: AppColors.textLight)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.categoryBg1, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  _buildPopupRow(Icons.home_outlined, 'Paket', widget.namaPaket, AppColors.primary),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1)),
                  _buildPopupRow(Icons.pets_outlined, 'Peliharaan', hewan['nama']!, AppColors.accent),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1)),
                  _buildPopupRow(Icons.login_outlined, 'Check-in', _formatTanggal(_checkIn), const Color(0xFF4CAF50)),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1)),
                  _buildPopupRow(Icons.logout_outlined, 'Check-out', _formatTanggal(_checkOut), const Color(0xFFE57373)),
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
              decoration: const BoxDecoration(color: Color(0xFFE0F5F2), shape: BoxShape.circle),
              child: const Center(child: Text('🎉', style: TextStyle(fontSize: 40))),
            ),
            const SizedBox(height: 20),
            const Text(
              'Booking Berhasil!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark),
            ),
            const SizedBox(height: 8),
            const Text(
              'Penitipan anabul kamu sudah dikonfirmasi.\nSampai jumpa di hari check-in ya!',
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
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(16)),
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