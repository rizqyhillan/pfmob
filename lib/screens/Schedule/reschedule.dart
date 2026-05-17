import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/tema_app.dart';

class RescheduleScreen extends StatefulWidget {
  final AppScheduleItem item;

  const RescheduleScreen({
    super.key,
    required this.item,
  });

  @override
  State<RescheduleScreen> createState() => _RescheduleScreenState();
}

class _RescheduleScreenState extends State<RescheduleScreen> {
  static const List<String> _pagiTimes = ['09:00', '10:00', '11:00'];
  static const List<String> _siangTimes = ['13:00', '14:00', '15:00', '16:00'];

  late DateTime _selectedDate;
  late DateTime _selectedCheckoutDate;
  late String _selectedTime;
  bool _saving = false;

  @override
  void initState() {
    super.initState();

    final oldDate = DateTime.tryParse(widget.item.date);
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    _selectedDate = _onlyDate(oldDate != null && !oldDate.isBefore(_onlyDate(DateTime.now())) ? oldDate : tomorrow);

    final oldCheckout = DateTime.tryParse(widget.item.raw['tanggal_rencana_keluar']?.toString() ?? '');
    _selectedCheckoutDate = _onlyDate(oldCheckout != null && oldCheckout.isAfter(_selectedDate)
        ? oldCheckout
        : _selectedDate.add(const Duration(days: 1)));

    final currentTime = widget.item.time;
    _selectedTime = (_pagiTimes.contains(currentTime) || _siangTimes.contains(currentTime)) ? currentTime : '10:00';
  }

  DateTime _onlyDate(DateTime value) => DateTime(value.year, value.month, value.day);

  String _formatDateForApi(DateTime value) {
    final y = value.year.toString().padLeft(4, '0');
    final m = value.month.toString().padLeft(2, '0');
    final d = value.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String _formatDateLabel(DateTime value) {
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${days[value.weekday - 1]}, ${value.day} ${months[value.month - 1]} ${value.year}';
  }

  Future<void> _pickDate({required bool checkout}) async {
    final now = _onlyDate(DateTime.now());
    final initial = checkout ? _selectedCheckoutDate : _selectedDate;
    final first = checkout ? _selectedDate.add(const Duration(days: 1)) : now;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(first) ? first : initial,
      firstDate: first,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (picked == null) return;

    setState(() {
      if (checkout) {
        _selectedCheckoutDate = _onlyDate(picked);
      } else {
        _selectedDate = _onlyDate(picked);
        if (!_selectedCheckoutDate.isAfter(_selectedDate)) {
          _selectedCheckoutDate = _selectedDate.add(const Duration(days: 1));
        }
      }
    });
  }

  Future<void> _save() async {
    if (_saving) return;

    setState(() => _saving = true);
    try {
      if (widget.item.type == 'doctor') {
        await ApiService.rescheduleDoctorBooking(
          id: widget.item.id,
          tanggalBooking: _formatDateForApi(_selectedDate),
          jamBooking: _selectedTime,
          idJadwal: int.tryParse(widget.item.raw['id_jadwal']?.toString() ?? ''),
        );
      } else if (widget.item.type == 'grooming') {
        await ApiService.rescheduleGroomingBooking(
          id: widget.item.id,
          tanggalGrooming: _formatDateForApi(_selectedDate),
          waktuGrooming: _selectedTime,
        );
      } else if (widget.item.type == 'boarding') {
        await ApiService.rescheduleBoarding(
          id: widget.item.id,
          tanggalMasuk: _formatDateForApi(_selectedDate),
          tanggalRencanaKeluar: _formatDateForApi(_selectedCheckoutDate),
        );
      }

      if (!mounted) return;
      await _showSuccessSheet();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _showSuccessSheet() async {
    await showModalBottomSheet<void>(
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
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 28),
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(color: Color(0xFFE8F5E9), shape: BoxShape.circle),
              child: const Center(child: Text('✅', style: TextStyle(fontSize: 40))),
            ),
            const SizedBox(height: 20),
            const Text('Reschedule Berhasil!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark)),
            const SizedBox(height: 8),
            Text(
              widget.item.type == 'boarding'
                  ? 'Jadwal baru: ${_formatDateLabel(_selectedDate)} sampai ${_formatDateLabel(_selectedCheckoutDate)}'
                  : 'Jadwal baru: ${_formatDateLabel(_selectedDate)} • $_selectedTime WIB',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.textLight, height: 1.5),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context, true);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(16)),
                child: const Text('Kembali ke Jadwal', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBoarding = widget.item.type == 'boarding';

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
                    _buildDatePickerCard(
                      title: isBoarding ? 'Tanggal Check-in Baru' : 'Tanggal Baru',
                      value: _formatDateLabel(_selectedDate),
                      onTap: () => _pickDate(checkout: false),
                    ),
                    if (isBoarding) ...[
                      const SizedBox(height: 16),
                      _buildDatePickerCard(
                        title: 'Rencana Check-out Baru',
                        value: _formatDateLabel(_selectedCheckoutDate),
                        onTap: () => _pickDate(checkout: true),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Durasi baru: ${_selectedCheckoutDate.difference(_selectedDate).inDays} hari',
                        style: const TextStyle(fontSize: 13, color: AppColors.textLight, fontWeight: FontWeight.w600),
                      ),
                    ] else ...[
                      const SizedBox(height: 24),
                      _buildWaktuBaru(),
                    ],
                  ],
                ),
              ),
            ),
            _buildSimpanButton(),
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
              width: 38,
              height: 38,
              decoration: BoxDecoration(color: AppColors.categoryBg1, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 16),
          const Text('Reschedule', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
        ],
      ),
    );
  }

  Widget _buildInfoLama() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Jadwal Saat Ini', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark)),
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
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: AppColors.categoryBg1, borderRadius: BorderRadius.circular(12)),
                    child: Center(child: Text(widget.item.emoji, style: const TextStyle(fontSize: 22))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.item.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                        Text(widget.item.subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textLight),
                  const SizedBox(width: 6),
                  Expanded(child: Text(widget.item.date, style: const TextStyle(fontSize: 13, color: AppColors.textMedium, fontWeight: FontWeight.w600))),
                  const Icon(Icons.access_time_outlined, size: 14, color: AppColors.textLight),
                  const SizedBox(width: 6),
                  Text(widget.item.time, style: const TextStyle(fontSize: 13, color: AppColors.textMedium, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.arrow_downward_rounded, color: AppColors.primary, size: 20),
          ),
        ),
        const SizedBox(height: 16),
        const Text('Jadwal Baru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark)),
      ],
    );
  }

  Widget _buildDatePickerCard({required String title, required String value, required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.divider)),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(color: AppColors.categoryBg1, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textLight, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(value, style: const TextStyle(fontSize: 15, color: AppColors.textDark, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            const Icon(Icons.edit_calendar_rounded, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildWaktuBaru() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pilih Waktu', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        const SizedBox(height: 14),
        Row(children: const [Icon(Icons.wb_sunny_outlined, size: 16, color: AppColors.gold), SizedBox(width: 6), Text('PAGI', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textLight, letterSpacing: 1))]),
        const SizedBox(height: 10),
        Wrap(spacing: 10, runSpacing: 10, children: _pagiTimes.map(_buildTimeChip).toList()),
        const SizedBox(height: 16),
        Row(children: const [Icon(Icons.cloud_outlined, size: 16, color: Color(0xFF4A9B8E)), SizedBox(width: 6), Text('SIANG & SORE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textLight, letterSpacing: 1))]),
        const SizedBox(height: 10),
        Wrap(spacing: 10, runSpacing: 10, children: _siangTimes.map(_buildTimeChip).toList()),
      ],
    );
  }

  Widget _buildTimeChip(String time) {
    final selected = _selectedTime == time;
    return GestureDetector(
      onTap: () => setState(() => _selectedTime = time),
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

  Widget _buildSimpanButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, -4))]),
      child: GestureDetector(
        onTap: _saving ? null : _save,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(color: _saving ? AppColors.textLight : AppColors.primary, borderRadius: BorderRadius.circular(16)),
          child: Center(
            child: _saving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Simpan Jadwal Baru', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
          ),
        ),
      ),
    );
  }
}
