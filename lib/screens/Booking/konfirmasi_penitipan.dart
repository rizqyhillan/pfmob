import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/tema_app.dart';

class KonfirmasiPenitipanScreen extends StatefulWidget {
  final BoardingRoom room;

  const KonfirmasiPenitipanScreen({super.key, required this.room});

  @override
  State<KonfirmasiPenitipanScreen> createState() => _KonfirmasiPenitipanScreenState();
}

class _KonfirmasiPenitipanScreenState extends State<KonfirmasiPenitipanScreen> {
  final TextEditingController _catatanController = TextEditingController();
  List<Pet> _pets = [];
  Pet? _selectedPet;
  DateTime _checkIn = DateTime.now().add(const Duration(days: 1));
  late DateTime _checkOut = _checkIn.add(const Duration(days: 1));
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  int get _durasi => _checkOut.difference(_checkIn).inDays <= 0 ? 1 : _checkOut.difference(_checkIn).inDays;
  double get _totalHarga => _durasi * widget.room.hargaPerHari;
  String _formatHarga(num harga) => harga.round().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  String _date(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _loadPets() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final pets = await ApiService.getMyPets();
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

  Future<void> _pickDate(bool isCheckIn) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isCheckIn ? _checkIn : _checkOut,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      if (isCheckIn) {
        _checkIn = picked;
        if (!_checkOut.isAfter(_checkIn)) _checkOut = _checkIn.add(const Duration(days: 1));
      } else if (picked.isAfter(_checkIn)) {
        _checkOut = picked;
      }
    });
  }

  Future<void> _submit() async {
    final pet = _selectedPet;
    if (pet == null || _saving) return;
    setState(() => _saving = true);
    try {
      final result = await ApiService.bookBoarding(
        idHewan: pet.id,
        idKamar: widget.room.id,
        tanggalMasuk: _date(_checkIn),
        tanggalRencanaKeluar: _date(_checkOut),
        catatan: _catatanController.text.trim(),
      );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Text('Booking penitipan berhasil'),
          content: Text('Hewan: ${result['nama_hewan'] ?? pet.nama}\nKamar: ${result['nama_kamar'] ?? widget.room.namaKamar}\nStatus: ${result['status'] ?? 'pending'}\nPembayaran dilakukan di lokasi.'),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
        ),
      );
      if (!mounted) return;
      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
    } finally {
      if (mounted) setState(() => _saving = false);
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
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? _message('⚠️', _error!, 'Coba Lagi', _loadPets)
                      : _pets.isEmpty
                          ? _message('🐾', 'Kamu belum punya data hewan. Tambahkan hewan dulu dari Profile > My Pets.', 'Muat ulang', _loadPets)
                          : SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                _roomCard(),
                                const SizedBox(height: 24),
                                _petPicker(),
                                const SizedBox(height: 24),
                                _datePickerRow(),
                                const SizedBox(height: 24),
                                TextField(controller: _catatanController, maxLines: 3, decoration: const InputDecoration(labelText: 'Catatan penitipan', hintText: 'Opsional')),
                                const SizedBox(height: 24),
                                _summaryCard(),
                              ]),
                            ),
            ),
            if (!_loading && _error == null && _pets.isNotEmpty) _bottomButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) => Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 0), child: Row(children: [GestureDetector(onTap: () => Navigator.pop(context), child: Container(width: 38, height: 38, decoration: BoxDecoration(color: AppColors.categoryBg1, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.primary))), const SizedBox(width: 16), const Text('Konfirmasi Penitipan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark))]));

  Widget _message(String icon, String title, String action, VoidCallback onAction) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [Text(icon, style: const TextStyle(fontSize: 48)), const SizedBox(height: 12), Text(title, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textMedium, fontWeight: FontWeight.w700)), const SizedBox(height: 12), ElevatedButton(onPressed: onAction, child: Text(action))])));

  Widget _roomCard() => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.divider)), child: Row(children: [Container(width: 56, height: 56, decoration: BoxDecoration(color: AppColors.categoryBg1, borderRadius: BorderRadius.circular(14)), child: const Center(child: Text('🏠', style: TextStyle(fontSize: 28)))), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(widget.room.namaKamar, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textDark)), Text(widget.room.paket, style: const TextStyle(fontSize: 12, color: AppColors.textLight)), Text('Rp ${_formatHarga(widget.room.hargaPerHari)} / hari', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primary))]))]));

  Widget _petPicker() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Pilih Peliharaan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark)), const SizedBox(height: 14), SizedBox(height: 116, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: _pets.length, separatorBuilder: (_, __) => const SizedBox(width: 12), itemBuilder: (_, i) { final pet = _pets[i]; final selected = _selectedPet?.id == pet.id; return GestureDetector(onTap: () => setState(() => _selectedPet = pet), child: Container(width: 104, padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: selected ? AppColors.categoryBg1 : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: selected ? AppColors.primary : AppColors.divider, width: selected ? 2 : 1)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(pet.jenis.toLowerCase().contains('anjing') ? '🐶' : '🐱', style: const TextStyle(fontSize: 34)), const SizedBox(height: 6), Text(pet.nama, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textDark)), Text(pet.jenis, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: AppColors.textLight))]))); }))]);

  Widget _datePickerRow() => Row(children: [Expanded(child: _dateTile('Check-in', _date(_checkIn), () => _pickDate(true))), const SizedBox(width: 12), Expanded(child: _dateTile('Check-out', _date(_checkOut), () => _pickDate(false)))]);
  Widget _dateTile(String title, String value, VoidCallback onTap) => GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.divider)), child: Row(children: [const Icon(Icons.calendar_today_outlined, color: AppColors.primary), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textLight)), Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textDark))]))])));

  Widget _summaryCard() => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.accentLight, borderRadius: BorderRadius.circular(18)), child: Column(children: [Row(children: [const Text('Durasi', style: TextStyle(color: AppColors.textMedium)), const Spacer(), Text('$_durasi hari', style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.textDark))]), const SizedBox(height: 8), Row(children: [const Text('Estimasi', style: TextStyle(color: AppColors.textMedium)), const Spacer(), Text('Rp ${_formatHarga(_totalHarga)}', style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary))]), const SizedBox(height: 8), const Text('Pembayaran dilakukan di lokasi. Tidak memakai payment gateway.', style: TextStyle(fontSize: 12, color: AppColors.textMedium))]));

  Widget _bottomButton() => Container(padding: const EdgeInsets.fromLTRB(20, 16, 20, 20), decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, -4))]), child: SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _saving ? null : _submit, child: Text(_saving ? 'Menyimpan...' : 'Buat Booking Penitipan'))));
}
