import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../viewmodels/booking_viewmodel.dart';
import '../../theme/tema_app.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../login.dart';
import 'data_pasien.dart';

class DokterDetailScreen extends StatefulWidget {
  final Doctor doctor;

  const DokterDetailScreen({super.key, required this.doctor});

  @override
  State<DokterDetailScreen> createState() => _DokterDetailScreenState();
}

class _DokterDetailScreenState extends State<DokterDetailScreen> {
  List<DoctorServiceItem> _services = [];
  List<Map<String, dynamic>> _days = [];
  DoctorServiceItem? _selectedService;
  int _selectedDay = 0;
  int _selectedTimeIndex = -1;
  Map<String, dynamic>? _selectedSlot;
  bool _loading = true;
  String? _error;

  final LayerLink _serviceDropdownLink = LayerLink();
  OverlayEntry? _serviceDropdownOverlay;

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }

  @override
  void dispose() {
    _closeServiceDropdown();
    super.dispose();
  }

  String _formatHarga(num harga) => harga.round().toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]}.',
      );

  Future<void> _loadOptions() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final bookingViewModel = context.read<BookingViewModel>();
      await bookingViewModel.loadDoctorDetail(doctorId: widget.doctor.id);

      if (!mounted) return;

      final services = bookingViewModel.doctorServices;
      final availability = bookingViewModel.doctorAvailability ?? <String, dynamic>{};
      final rawDays = availability['days'] as List? ?? [];
      final days =
          rawDays.map((e) => Map<String, dynamic>.from(e as Map)).toList();

      int firstAvailableDay = 0;
      Map<String, dynamic>? firstSlot;

      for (int i = 0; i < days.length; i++) {
        final allSlots = _slotsFromDay(days[i]);
        if (allSlots.isNotEmpty) {
          firstAvailableDay = i;
          firstSlot = allSlots.first;
          break;
        }
      }

      setState(() {
        _services = services;
        _days = days;
        _selectedService = services.isNotEmpty ? services.first : null;
        _selectedDay = firstAvailableDay;
        _selectedTimeIndex = firstSlot == null ? -1 : 0;
        _selectedSlot = firstSlot;
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

  List<Map<String, dynamic>> _slotsFromDay(Map<String, dynamic> day) {
    final times = Map<String, dynamic>.from(day['times'] ?? {});
    final pagi = (times['pagi'] as List? ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    final siang = (times['siang'] as List? ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    return [...pagi, ...siang];
  }

  List<Map<String, dynamic>> _slotsForSelectedDay(String group) {
    if (_days.isEmpty) return [];

    final day = _days[_selectedDay];
    final times = Map<String, dynamic>.from(day['times'] ?? {});
    final raw = times[group] as List? ?? [];

    return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

void _toggleServiceDropdown() {
  if (_serviceDropdownOverlay != null) {
    _closeServiceDropdown();
    return;
  }

  _serviceDropdownOverlay = OverlayEntry(
    builder: (context) {
      return Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _closeServiceDropdown,
              behavior: HitTestBehavior.translucent,
              child: Container(color: Colors.transparent),
            ),
          ),
          CompositedTransformFollower(
            link: _serviceDropdownLink,
            showWhenUnlinked: false,
            offset: const Offset(0, 58),
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              tween: Tween<double>(begin: 0, end: 1),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, -8 * (1 - value)),
                    child: Transform.scale(
                      scale: 0.96 + (0.04 * value),
                      alignment: Alignment.topCenter,
                      child: child,
                    ),
                  ),
                );
              },
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: MediaQuery.of(context).size.width - 40,
                  constraints: const BoxConstraints(
                    maxHeight: 240,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shrinkWrap: true,
                      itemCount: _services.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color: Colors.grey.withValues(alpha: 0.16),
                      ),
                      itemBuilder: (context, index) {
                        final s = _services[index];
                        final selected = _selectedService?.id == s.id;

                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedService = s;
                            });
                            _closeServiceDropdown();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 13,
                            ),
                            color: selected
                                ? AppColors.primary.withValues(alpha: 0.08)
                                : Colors.white,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${s.namaLayanan} - Rp ${_formatHarga(s.harga)}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: selected
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                      color: selected
                                          ? AppColors.primary
                                          : AppColors.textDark,
                                    ),
                                  ),
                                ),
                                if (selected)
                                  const Icon(
                                    Icons.check_rounded,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );

  Overlay.of(context).insert(_serviceDropdownOverlay!);
}

  void _closeServiceDropdown() {
    _serviceDropdownOverlay?.remove();
    _serviceDropdownOverlay = null;
  }

  void _selectDay(int index) {
    final allSlots = _slotsFromDay(_days[index]);

    setState(() {
      _selectedDay = index;
      _selectedTimeIndex = allSlots.isEmpty ? -1 : 0;
      _selectedSlot = allSlots.isEmpty ? null : allSlots.first;
    });
  }

  void _continue() {
    final service = _selectedService;
    final slot = _selectedSlot;

    if (service == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih layanan dulu')),
      );
      return;
    }

    if (_days.isEmpty || slot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal dan jam dokter dulu')),
      );
      return;
    }

    if (!context.read<AuthViewModel>().isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(redirectToProfile: false),
        ),
      );
      return;
    }

    final selectedDay = _days[_selectedDay];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DataPasienScreen(
          doctor: widget.doctor,
          service: service,
          schedule: DoctorScheduleItem(
            id: int.tryParse(slot['id_jadwal'].toString()) ?? 0,
            idDokter: widget.doctor.id,
            hari: selectedDay['hari']?.toString() ?? '-',
            jamMulai: slot['jam_mulai']?.toString() ?? '',
            jamSelesai: slot['jam_selesai']?.toString() ?? '',
          ),
          tanggalBooking: selectedDay['full_date'].toString(),
          jamBooking: slot['time'].toString(),
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
            _buildHeader(),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? _message(_error!)
                      : SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _doctorCard(),
                              const SizedBox(height: 20),
                              _serviceSection(),
                              const SizedBox(height: 20),
                              _doctorDateSection(),
                              const SizedBox(height: 20),
                              _doctorTimeSection(),
                              const SizedBox(height: 14),
                              _paymentNote(),
                            ],
                          ),
                        ),
            ),
            _bottomButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 38,
                height: 38,
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
              'Detail Dokter',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      );

  Widget _message(String msg) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⚠️', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(msg, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadOptions,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );

  Widget _doctorCard() => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 34,
              backgroundColor: AppColors.categoryBg3,
              child: ClipOval(
                child: _isValidUrl(widget.doctor.fotoUrl)
                    ? Image.network(
                        _getBustedUrl(widget.doctor.fotoUrl!),
                        width: 68,
                        height: 68,
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
                          width: 68,
                          height: 68,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Image.asset(
                        'assets/images/pet-dokter.png',
                        width: 68,
                        height: 68,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.doctor.nama,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.doctor.spesialis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '⭐ ${widget.doctor.rating.toStringAsFixed(1)} • ${widget.doctor.pengalaman}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _serviceSection() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pilih Layanan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 10),
          if (_services.isEmpty)
            const Text(
              'Layanan dokter belum tersedia.',
              style: TextStyle(color: AppColors.textLight),
            )
          else
            CompositedTransformTarget(
              link: _serviceDropdownLink,
              child: GestureDetector(
                onTap: _toggleServiceDropdown,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 15,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedService == null
                              ? 'Pilih layanan dokter'
                              : '${_selectedService!.namaLayanan} - Rp ${_formatHarga(_selectedService!.harga)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _selectedService == null
                                ? AppColors.textLight
                                : AppColors.textDark,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (_selectedService != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedService!.namaLayanan,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  if (_selectedService!.deskripsi.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      _selectedService!.deskripsi,
                      style: const TextStyle(
                        color: AppColors.textLight,
                        height: 1.35,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    'Estimasi Rp ${_formatHarga(_selectedService!.harga)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      );

  Widget _doctorDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Pilih Tanggal',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            Text(
              _days.isNotEmpty
                  ? (_days[_selectedDay]['month_year'] ?? '').toString()
                  : '',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.gold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (_days.isEmpty)
          const Text(
            'Jadwal dokter belum diatur oleh admin.',
            style: TextStyle(color: AppColors.textLight),
          )
        else
          SizedBox(
            height: 76,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _days.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final day = _days[i];
                final selected = _selectedDay == i;
                final available = day['available'] == true;

                return GestureDetector(
                  onTap: available ? () => _selectDay(i) : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 58,
                    height: 68,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            selected ? AppColors.primary : AppColors.divider,
                      ),
                    ),
                    child: Opacity(
                      opacity: available ? 1 : 0.45,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            (day['day'] ?? '-').toString(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: selected
                                  ? Colors.white70
                                  : AppColors.textLight,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            (day['date'] ?? '-').toString(),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: selected
                                  ? Colors.white
                                  : AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _doctorTimeSection() {
    final pagi = _slotsForSelectedDay('pagi');
    final siang = _slotsForSelectedDay('siang');

    if (pagi.isEmpty && siang.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: const Text(
          'Dokter tidak tersedia pada tanggal ini.',
          style: TextStyle(
            color: AppColors.textLight,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Waktu Kunjungan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 14),
        if (pagi.isNotEmpty) ...[
          const Row(
            children: [
              Icon(Icons.wb_sunny_outlined, size: 16, color: AppColors.gold),
              SizedBox(width: 6),
              Text(
                'PAGI',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textLight,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(
              pagi.length,
              (i) => _doctorTimeChip(pagi[i], i),
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (siang.isNotEmpty) ...[
          const Row(
            children: [
              Icon(Icons.cloud_outlined, size: 16, color: Color(0xFF4A9B8E)),
              SizedBox(width: 6),
              Text(
                'SIANG & SORE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textLight,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(
              siang.length,
              (i) => _doctorTimeChip(siang[i], i + pagi.length),
            ),
          ),
        ],
      ],
    );
  }

  Widget _doctorTimeChip(Map<String, dynamic> slot, int index) {
    final selected = _selectedTimeIndex == index;
    final time = (slot['time'] ?? '-').toString();

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTimeIndex = index;
          _selectedSlot = slot;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
          ),
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

  Widget _paymentNote() => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.accentLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            Icon(Icons.payments_outlined, color: AppColors.accent),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Pembayaran dokter: Bayar di lokasi. Tidak memakai payment gateway.',
                style: TextStyle(fontSize: 12, color: AppColors.textMedium),
              ),
            ),
          ],
        ),
      );

  Widget _bottomButton() => Container(
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
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _continue,
            child: const Text('Lanjut Isi Data Pasien'),
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