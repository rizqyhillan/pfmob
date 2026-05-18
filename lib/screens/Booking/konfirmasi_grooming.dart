import 'package:flutter/material.dart';
import '../../theme/tema_app.dart';
import '../Home/dashboard.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';

class KonfirmasiGroomingScreen extends StatefulWidget {
  final int idPaket;
  final String namaPaket;
  final String harga;
  const KonfirmasiGroomingScreen({super.key, required this.idPaket, required this.namaPaket, required this.harga});

  @override
  State<KonfirmasiGroomingScreen> createState() => _KonfirmasiGroomingScreenState();
}

class _KonfirmasiGroomingScreenState extends State<KonfirmasiGroomingScreen> {
  int _selectedDay = 0;
  int _selectedTime = 0;
  int _selectedHewan = -1;

  List<Pet> _myPets = [];
  List<Map<String, dynamic>> _days = [];
  List<String> _pagiTimes = [];
  List<String> _siangTimes = [];
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final pets = await ApiService.getMyPets();
      final avail = await ApiService.getGroomingAvailability();
      
      if (!mounted) return;
      setState(() {
        _myPets = pets;
        if (_myPets.isNotEmpty) _selectedHewan = 0;
        
        _days = List<Map<String, dynamic>>.from(avail['days']);
        _pagiTimes = List<String>.from(avail['times']['pagi']);
        _siangTimes = List<String>.from(avail['times']['siang']);
        
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      setState(() => _isLoading = false);
    }
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
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : SingleChildScrollView(
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
            if (!_isLoading) _buildNextButton(context),
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
             Image.asset(
                'assets/images/grooming.png',
                width: 56,
                height: 56,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.content_cut,
                  color: AppColors.primary,
                  size: 28,
                ),
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
          child: _myPets.isEmpty 
          ? const Center(child: Text('Belum ada hewan peliharaan', style: TextStyle(color: AppColors.textLight)))
          : ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _myPets.length,
            itemBuilder: (context, i) {
              final h = _myPets[i];
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
                        child: ClipOval(
                          child: h.foto.isNotEmpty 
                            ? Image.network('${ApiConfig.baseUrl.replaceAll('/api', '')}/storage/${h.foto}', width: 68, height: 68, fit: BoxFit.cover)
                            : Center(child: Text(h.jenis.toLowerCase() == 'kucing' ? '🐱' : (h.jenis.toLowerCase() == 'anjing' ? '🐶' : '🐾'), style: const TextStyle(fontSize: 36))),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        h.nama,
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
          children: [
            const Text('Pilih Tanggal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark)),
            Text(_days.isNotEmpty ? _days[_selectedDay]['month_year'] : '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.gold)),
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
                    Text(_days[i]['day'].toString(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? Colors.white70 : AppColors.textLight)),
                    const SizedBox(height: 4),
                    Text(_days[i]['date'].toString(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: selected ? Colors.white : AppColors.textDark)),
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
    if (_myPets.isEmpty || _selectedHewan < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih hewan peliharaan terlebih dahulu')),
      );
      return;
    }
    final hewan = _myPets[_selectedHewan];
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
            // Handle bar
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Header paket
            Row(
              children: [
                Image.asset(
                  'assets/images/grooming.png',
                  width: 52,
                  height: 52,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.content_cut,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.namaPaket,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      '${hewan.nama} • ${hewan.jenis}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Info rows
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildInfoRow('Paket', 'Grooming ${widget.namaPaket}'),
                  const SizedBox(height: 14),
                  _buildInfoRow('Peliharaan', hewan.nama),
                  const SizedBox(height: 14),
                  _buildInfoRow(
                    'Tanggal grooming',
                    '${hari['day']}, ${hari['date']} ${hari['month_year']}',
                  ),
                  const SizedBox(height: 14),
                  _buildInfoRow('Waktu', '$waktu WIB'),
                  const SizedBox(height: 14),
                  _buildInfoRow('Estimasi biaya', widget.harga),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Info pembayaran
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F5F2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Pembayaran dilakukan di lokasi setelah layanan selesai.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.accent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Tombol aksi
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.categoryBg1,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Text(
                        'Ubah',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _submitBooking(hewan.id, hari['full_date'], waktu);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Text(
                        'Ya, Konfirmasi!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
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

  // Helper baru — ganti _buildPopupRow yang lama
  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textLight,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }

  Future<void> _submitBooking(int idHewan, String tanggal, String waktu) async {
    setState(() => _isSubmitting = true);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );
    
    try {
      await ApiService.bookGrooming(
        idHewan: idHewan,
        idPaket: widget.idPaket,
        tanggalGrooming: tanggal,
        waktuGrooming: waktu,
      );
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // Tutup loading dialog
      _showSuksesPopup(context);
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // Tutup loading dialog
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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