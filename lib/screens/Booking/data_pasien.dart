import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../viewmodels/booking_viewmodel.dart';
import '../../theme/tema_app.dart';

class DataPasienScreen extends StatefulWidget {
  final Doctor doctor;
  final DoctorServiceItem service;
  final DoctorScheduleItem? schedule;
  final String tanggalBooking;
  final String jamBooking;

  const DataPasienScreen({
    super.key,
    required this.doctor,
    required this.service,
    required this.schedule,
    required this.tanggalBooking,
    required this.jamBooking,
  });

  @override
  State<DataPasienScreen> createState() => _DataPasienScreenState();
}

class _DataPasienScreenState extends State<DataPasienScreen> {
  final TextEditingController _keluhanController = TextEditingController();
  List<Pet> _pets = [];
  Pet? _selectedPet;
  bool _loading = true;
  bool _saving = false;
  String? _error;
  final List<String> _quickKeluhan = ['Nafsu Makan Turun', 'Lemas', 'Muntah', 'Gatal-gatal'];

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  @override
  void dispose() {
    _keluhanController.dispose();
    super.dispose();
  }

  String _formatHarga(num harga) => harga.round().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

  Future<void> _loadPets() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final pets = await context.read<BookingViewModel>().loadPets();
      if (!mounted) return;
      setState(() {
        _pets = pets;
        _selectedPet = pets.isNotEmpty ? pets.first : null;
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

  Future<void> _submit() async {
    final pet = _selectedPet;
    if (pet == null || _saving) return;
    setState(() => _saving = true);
    try {
      final bookingViewModel = context.read<BookingViewModel>();
      await bookingViewModel.bookDoctor(
        idHewan: pet.id,
        idDokter: widget.doctor.id,
        idLayanan: widget.service.id,
        idJadwal: widget.schedule?.id,
        tanggalBooking: widget.tanggalBooking,
        jamBooking: widget.jamBooking,
        keluhan: _keluhanController.text.trim(),
      );
      if (!mounted) return;
      _showSuksesPopup(context);
    } catch (e) {
      if (mounted) {
        final errorMsg = e.toString().replaceFirst('Exception: ', '');
        final lowerMsg = errorMsg.toLowerCase();
        
        if (lowerMsg.contains('tersedia') || 
            lowerMsg.contains('jadwal') || 
            lowerMsg.contains('penuh') || 
            lowerMsg.contains('dipesan') ||
            lowerMsg.contains('diambil')) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              title: const Text('Jadwal Tidak Tersedia', style: TextStyle(fontWeight: FontWeight.bold)),
              content: Text(errorMsg),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context, true);
                  },
                  child: const Text('Pilih Jadwal Lain'),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMsg)),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showSuksesPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
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
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 28),
            Image.asset(
              'assets/images/check.png',
              width: 80,
              height: 80,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            const Text(
              'Booking Berhasil!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Booking dokter kamu sudah dikonfirmasi.\nSampai jumpa di hari H ya!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textLight,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () => Navigator.popUntil(context, (route) => route.isFirst),
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
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? _message(Image.asset('assets/images/warning.png', width: 56, height: 56), _error!, 'Coba Lagi', _loadPets)
                  : _pets.isEmpty
                  ? _message(Image.asset('assets/images/logo-paw.png', width: 56, height: 56), 'Kamu belum punya data hewan. Tambahkan hewan dulu dari Profile > My Pets.', 'Muat ulang', _loadPets)
                          : SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _summaryCard(),
                                  const SizedBox(height: 24),
                                  _buildPilihHewan(),
                                  const SizedBox(height: 24),
                                  _buildKeluhan(),
                                ],
                              ),
                            ),
            ),
            if (!_loading && _error == null && _pets.isNotEmpty) _bottomButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Row(children: [
          GestureDetector(onTap: () => Navigator.pop(context), child: Container(width: 38, height: 38, decoration: BoxDecoration(color: AppColors.categoryBg1, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.primary))),
          const SizedBox(width: 16),
          const Text('Data Pasien', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
        ]),
      );

  Widget _message(Widget icon, String title, String action, VoidCallback onAction) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [icon, const SizedBox(height: 12), Text(title, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textMedium, fontWeight: FontWeight.w700)), const SizedBox(height: 12), ElevatedButton(onPressed: onAction, child: Text(action))])));

  Widget _summaryCard() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.divider)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.service.namaLayanan, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textDark)),
          const SizedBox(height: 6),
          Text('${widget.doctor.nama} • ${widget.tanggalBooking} ${widget.jamBooking}', style: const TextStyle(fontSize: 12, color: AppColors.textMedium)),
          const SizedBox(height: 8),
          Text('Estimasi Rp ${_formatHarga(widget.service.harga)} • Bayar di lokasi', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primary)),
        ]),
      );

  Widget _buildPilihHewan() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Pilih Hewan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark)),
      const SizedBox(height: 14),
      SizedBox(
        height: 110,
        child: _pets.isEmpty
            ? const Center(child: Text('Belum ada hewan peliharaan', style: TextStyle(color: AppColors.textLight)))
            : ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _pets.length,
                itemBuilder: (_, i) {
                  final pet = _pets[i];
                  final selected = _selectedPet?.id == pet.id;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedPet = pet),
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
                              child: pet.foto.isNotEmpty
                            ? Image.network(pet.foto, width: 68, height: 68, fit: BoxFit.cover)
                            : Center(child: Text(pet.jenis.toLowerCase() == 'kucing' ? '🐱' : (pet.jenis.toLowerCase() == 'anjing' ? '🐶' : '🐾'), style: const TextStyle(fontSize: 36))),
                                    ),
                            ),
                          const SizedBox(height: 6),
                          Text(
                            pet.nama,
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
  Widget _buildKeluhan() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Ceritakan Keluhan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark)),
        const SizedBox(height: 10),
        TextField(controller: _keluhanController, maxLines: 4, decoration: const InputDecoration(hintText: 'Contoh: lemas dan tidak mau makan sejak pagi...')),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: _quickKeluhan.map((k) => GestureDetector(onTap: () => setState(() => _keluhanController.text += _keluhanController.text.isEmpty ? k : ', $k'), child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.divider)), child: Text(k, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMedium))))).toList()),
      ]);

  Widget _bottomButton() => Container(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20), 
    decoration: BoxDecoration(
      color: Colors.white, 
      boxShadow: [BoxShadow(
        color: Colors.black.withValues(alpha: 0.06), 
        blurRadius: 16, 
        offset: const Offset(0, -4)
        )
      ]), 
    child: SizedBox(
      width: double.infinity, 
      child: ElevatedButton(
        onPressed: _saving ? null : _submit, 
        child: Text(_saving ? 'Menyimpan...' : 'Buat Booking')
        )
      )
    );
}
