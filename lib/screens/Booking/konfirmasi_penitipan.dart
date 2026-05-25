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

  int get _durasi =>
      _checkOut.difference(_checkIn).inDays <= 0
          ? 1
          : _checkOut.difference(_checkIn).inDays;

  double get _totalHarga => _durasi * widget.room.hargaPerHari;

  String _formatHarga(num harga) => harga
      .round()
      .toString()
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

  String _date(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _dateDisplay(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')} / ${d.month.toString().padLeft(2, '0')} / ${d.year}';

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
    final minimumCheckOut = _checkIn.add(const Duration(days: 1));
    final picked = await showDatePicker(
      context: context,
      initialDate: isCheckIn
          ? _checkIn
          : (_checkOut.isAfter(_checkIn) ? _checkOut : minimumCheckOut),
      firstDate: isCheckIn ? DateTime.now() : minimumCheckOut,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isCheckIn) {
        _checkIn = picked;
        if (!_checkOut.isAfter(_checkIn)) {
          _checkOut = _checkIn.add(const Duration(days: 1));
        }
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
      await ApiService.bookBoarding(
        idHewan: pet.id,
        idKamar: widget.room.id,
        tanggalMasuk: _date(_checkIn),
        tanggalRencanaKeluar: _date(_checkOut),
        catatan: _catatanController.text.trim(),
      );
      if (!mounted) return;
      _showSuksesPopup(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
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
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primary))
                  : _error != null
                      ? _buildMessage('⚠️', _error!, 'Coba Lagi', _loadPets)
                      : _pets.isEmpty
                          ? _buildMessage(
                              '🐾',
                              'Kamu belum punya data hewan.\nTambahkan hewan dulu dari Profile > My Pets.',
                              'Muat ulang',
                              _loadPets,
                            )
                          : SingleChildScrollView(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 16, 20, 24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildRoomCard(),
                                  const SizedBox(height: 24),
                                  _buildPetPicker(),
                                  const SizedBox(height: 24),
                                  _buildDatePickerRow(),
                                  const SizedBox(height: 24),
                                  _buildCatatan(),
                                  const SizedBox(height: 24),
                                  _buildSummaryCard(),
                                ],
                              ),
                            ),
            ),
            if (!_loading && _error == null && _pets.isNotEmpty)
              _buildBottomButton(),
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
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Konfirmasi Penitipan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(
      String icon, String title, String action, VoidCallback onAction) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textMedium,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: onAction,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  action,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.categoryBg1,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/images/pet-boarding.png',
            width: 56, height: 56,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.home_outlined,
                  color: AppColors.primary, size: 28),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.room.namaKamar,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  widget.room.paket,
                  style: const TextStyle(fontSize: 12, color: AppColors.textLight),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.payments_outlined,
                        size: 13, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      'Rp ${_formatHarga(widget.room.hargaPerHari)} / hari',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilih Peliharaan',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark),
        ),
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
                                    ? Image.network(
                                        pet.foto,
                                        width: 68, height: 68,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Center(
                                          child: Text(
                                            pet.jenis.toLowerCase() == 'kucing' ? '🐱' :
                                            pet.jenis.toLowerCase() == 'anjing' ? '🐶' : '🐾',
                                            style: const TextStyle(fontSize: 36),
                                          ),
                                        ),
                                      )
                                    : Center(
                                        child: Text(
                                          pet.jenis.toLowerCase() == 'kucing' ? '🐱' :
                                          pet.jenis.toLowerCase() == 'anjing' ? '🐶' : '🐾',
                                          style: const TextStyle(fontSize: 36),
                                        ),
                                      ),
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
  }

  Widget _buildDatePickerRow() {
    return Row(
      children: [
        Expanded(child: _buildDateTile('Check-in', _checkIn, () => _pickDate(true))),
        const SizedBox(width: 12),
        Expanded(child: _buildDateTile('Check-out', _checkOut, () => _pickDate(false))),
      ],
    );
  }

  Widget _buildDateTile(String title, DateTime value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined,
                color: AppColors.primary, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textLight)),
                  Text(
                    _dateDisplay(value),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCatatan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Catatan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.divider),
          ),
          child: TextField(
            controller: _catatanController,
            maxLines: 3,
            style: const TextStyle(fontSize: 14, color: AppColors.textDark),
            decoration: const InputDecoration(
              hintText: 'Catatan penitipan (opsional)',
              hintStyle: TextStyle(color: AppColors.textLight, fontSize: 14),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          _buildInfoRow('Durasi', '$_durasi hari'),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ESTIMASI BIAYA',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'Rp ${_formatHarga(_totalHarga)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
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
                Text(
                  'Pembayaran dilakukan di tempat',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () => _showRingkasanPopup(context),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Text(
            'Lanjutkan',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  void _showRingkasanPopup(BuildContext context) {
    final pet = _selectedPet;
    if (pet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih hewan peliharaan terlebih dahulu')),
      );
      return;
    }

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

            // Header
            Row(
              children: [
                Image.asset(
                  'assets/images/pet-boarding.png',
                  width: 52, height: 52,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.home_outlined,
                    color: AppColors.primary,
                    size: 36,
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.room.namaKamar,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      '${pet.nama} • ${pet.jenis}',
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
                  _buildInfoRow('Kamar', widget.room.namaKamar),
                  const SizedBox(height: 14),
                  _buildInfoRow('Paket', widget.room.paket),
                  const SizedBox(height: 14),
                  _buildInfoRow('Peliharaan', '${pet.nama} • ${pet.jenis}'),
                  const SizedBox(height: 14),
                  _buildInfoRow('Check-in', _dateDisplay(_checkIn)),
                  const SizedBox(height: 14),
                  _buildInfoRow('Check-out', _dateDisplay(_checkOut)),
                  const SizedBox(height: 14),
                  _buildInfoRow('Durasi', '$_durasi hari'),
                  const SizedBox(height: 14),
                  _buildInfoRow('Estimasi biaya', 'Rp ${_formatHarga(_totalHarga)}'),
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
                      _submit();
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
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Booking penitipan kamu sudah dikonfirmasi.\nSampai jumpa di hari H ya!',
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
}