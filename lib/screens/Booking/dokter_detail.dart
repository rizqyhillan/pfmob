import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/tema_app.dart';
import 'data_pasien.dart';

class DokterDetailScreen extends StatefulWidget {
  final Doctor doctor;

  const DokterDetailScreen({super.key, required this.doctor});

  @override
  State<DokterDetailScreen> createState() => _DokterDetailScreenState();
}

class _DokterDetailScreenState extends State<DokterDetailScreen> {
  List<DoctorServiceItem> _services = [];
  List<DoctorScheduleItem> _schedules = [];
  DoctorServiceItem? _selectedService;
  DoctorScheduleItem? _selectedSchedule;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }

  String _formatHarga(num harga) => harga.round().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  String _date(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  String _time(TimeOfDay t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _loadOptions() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        ApiService.getDoctorServices(doctorId: widget.doctor.id),
        ApiService.getDoctorSchedules(doctorId: widget.doctor.id),
      ]);
      if (!mounted) return;
      final services = results[0] as List<DoctorServiceItem>;
      final schedules = results[1] as List<DoctorScheduleItem>;
      setState(() {
        _services = services;
        _schedules = schedules;
        _selectedService = services.isNotEmpty ? services.first : null;
        _selectedSchedule = schedules.isNotEmpty ? schedules.first : null;
        if (_selectedSchedule != null && _selectedSchedule!.jamMulai.length >= 5) {
          final parts = _selectedSchedule!.jamMulai.split(':');
          _selectedTime = TimeOfDay(hour: int.tryParse(parts[0]) ?? 9, minute: int.tryParse(parts[1]) ?? 0);
        }
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _selectedTime);
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _continue() {
    final service = _selectedService;
    if (service == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih layanan dulu')));
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DataPasienScreen(
          doctor: widget.doctor,
          service: service,
          schedule: _selectedSchedule,
          tanggalBooking: _date(_selectedDate),
          jamBooking: _time(_selectedTime),
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
                              _scheduleSection(),
                              const SizedBox(height: 20),
                              _dateTimeSection(),
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
              child: Container(width: 38, height: 38, decoration: BoxDecoration(color: AppColors.categoryBg1, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.primary)),
            ),
            const SizedBox(width: 16),
            const Text('Detail Dokter', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
          ],
        ),
      );

  Widget _message(String msg) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [const Text('⚠️', style: TextStyle(fontSize: 48)), const SizedBox(height: 12), Text(msg, textAlign: TextAlign.center), const SizedBox(height: 12), ElevatedButton(onPressed: _loadOptions, child: const Text('Coba Lagi'))])));

  Widget _doctorCard() => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.divider)),
        child: Row(children: [
          const CircleAvatar(radius: 34, backgroundColor: AppColors.categoryBg3, child: Text('👩‍⚕️', style: TextStyle(fontSize: 34))),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(widget.doctor.nama, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textDark)), const SizedBox(height: 4), Text(widget.doctor.spesialis, style: const TextStyle(fontSize: 13, color: AppColors.textLight)), const SizedBox(height: 6), Text('⭐ ${widget.doctor.rating.toStringAsFixed(1)} • ${widget.doctor.pengalaman}', style: const TextStyle(fontSize: 12, color: AppColors.textMedium))])),
        ]),
      );

  Widget _serviceSection() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Pilih Layanan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark)),
        const SizedBox(height: 10),
        ..._services.map((s) => Padding(padding: const EdgeInsets.only(bottom: 10), child: _optionTile(selected: _selectedService?.id == s.id, title: s.namaLayanan, subtitle: s.deskripsi.isEmpty ? 'Estimasi Rp ${_formatHarga(s.harga)}' : '${s.deskripsi}\nEstimasi Rp ${_formatHarga(s.harga)}', onTap: () => setState(() => _selectedService = s)))).toList(),
      ]);

  Widget _scheduleSection() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Jadwal Dokter', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark)),
        const SizedBox(height: 10),
        if (_schedules.isEmpty) const Text('Jadwal belum diatur. Kamu tetap bisa pilih tanggal dan jam manual.', style: TextStyle(color: AppColors.textLight))
        else ..._schedules.map((s) => Padding(padding: const EdgeInsets.only(bottom: 10), child: _optionTile(selected: _selectedSchedule?.id == s.id, title: s.hari.toUpperCase(), subtitle: '${s.jamMulai} - ${s.jamSelesai}', onTap: () => setState(() { _selectedSchedule = s; if (s.jamMulai.length >= 5) { final p = s.jamMulai.split(':'); _selectedTime = TimeOfDay(hour: int.tryParse(p[0]) ?? 9, minute: int.tryParse(p[1]) ?? 0); } })))).toList(),
      ]);

  Widget _dateTimeSection() => Row(children: [
        Expanded(child: _pickTile(Icons.calendar_today_outlined, 'Tanggal', _date(_selectedDate), _pickDate)),
        const SizedBox(width: 12),
        Expanded(child: _pickTile(Icons.access_time_rounded, 'Jam', _time(_selectedTime), _pickTime)),
      ]);

  Widget _pickTile(IconData icon, String title, String value, VoidCallback onTap) => GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.divider)), child: Row(children: [Icon(icon, color: AppColors.primary), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textLight)), Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textDark))]))])));

  Widget _optionTile({required bool selected, required String title, required String subtitle, required VoidCallback onTap}) => GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: selected ? AppColors.categoryBg1 : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: selected ? AppColors.primary : AppColors.divider)), child: Row(children: [Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off, color: selected ? AppColors.primary : AppColors.textLight), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark)), const SizedBox(height: 3), Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textLight, height: 1.35))]))])));

  Widget _paymentNote() => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppColors.accentLight, borderRadius: BorderRadius.circular(16)), child: const Row(children: [Icon(Icons.payments_outlined, color: AppColors.accent), SizedBox(width: 10), Expanded(child: Text('Pembayaran dokter: Bayar di lokasi. Tidak memakai payment gateway.', style: TextStyle(fontSize: 12, color: AppColors.textMedium)))]));

  Widget _bottomButton() => Container(padding: const EdgeInsets.fromLTRB(20, 16, 20, 20), decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, -4))]), child: SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _continue, child: const Text('Lanjut Isi Data Pasien'))));
}
