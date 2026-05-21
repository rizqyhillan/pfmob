import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/servis_auth.dart';
import '../../theme/tema_app.dart';
import '../login.dart';
import '../../widgets/user_avatar.dart';
import 'reschedule.dart';

class ScheduleContent extends StatefulWidget {
  const ScheduleContent({super.key});

  @override
  State<ScheduleContent> createState() => _ScheduleContentState();
}

class _ScheduleContentState extends State<ScheduleContent> {
  int _selectedTab = 0;
  bool _loading = false;
  int? _cancellingId;
  String? _error;
  List<AppScheduleItem> _items = [];

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    if (!AuthService().isLoggedIn) {
      setState(() {
        _loading = false;
        _items = [];
        _error = null;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        ApiService.getMyDoctorBookings(),
        ApiService.getMyGroomingBookings(),
        ApiService.getMyBoardings(),
      ]);

      final merged = <AppScheduleItem>[
        ...results[0],
        ...results[1],
        ...results[2],
      ];

      merged.sort((a, b) => b.date.compareTo(a.date));

      if (!mounted) return;
      setState(() {
        _items = merged;
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

  List<AppScheduleItem> get _filteredItems {
    if (_selectedTab == 0) {
      return _items.where((item) => !item.isHistory).toList();
    }
    return _items.where((item) => item.isHistory).toList();
  }

  String get _displayName {
    final name = AuthService().userName.trim();
    if (name.isEmpty) return 'PawPet User';
    return name;
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
      case 'completed':
        return const Color(0xFF4A9B8E);
      case 'batal':
      case 'dibatalkan':
      case 'cancelled':
        return const Color(0xFFE57373);
      case 'dikonfirmasi':
      case 'confirmed':
      case 'aktif':
        return const Color(0xFF4A9B8E);
      case 'pending':
      default:
        return const Color(0xFFFF9800);
    }
  }

  String _statusLabel(String status) {
    return status.replaceAll('_', ' ').toUpperCase();
  }

  String _dateLabel(String date) {
    if (date == '-' || date.isEmpty) return 'JADWAL';
    return date;
  }

  Future<void> _showDetail(AppScheduleItem item) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ScheduleDetailSheet(
        item: item,
        statusColor: _statusColor(item.status),
        statusLabel: _statusLabel(item.status),
        onCancel: item.canCancel ? () => _cancelBooking(item) : null,
        onReschedule: item.canReschedule
            ? () {
                Navigator.of(context).maybePop();
                _rescheduleBooking(item);
              }
            : null,
        cancelling: _cancellingId == item.id,
      ),
    );
  }

  Future<void> _cancelBooking(AppScheduleItem item) async {
    if (!item.canCancel || _cancellingId != null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Batalkan Booking?'),
        content: Text('Booking ${item.serviceTypeLabel.toLowerCase()} ini akan dibatalkan. Aksi ini tidak bisa dibatalkan dari aplikasi.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Tidak')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Ya, Batalkan')),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _cancellingId = item.id);
    try {
      if (item.type == 'doctor') {
        await ApiService.cancelDoctorBooking(item.id);
      } else if (item.type == 'grooming') {
        await ApiService.cancelGroomingBooking(item.id);
      } else if (item.type == 'boarding') {
        await ApiService.cancelBoarding(item.id);
      }

      if (!mounted) return;
      Navigator.of(context).maybePop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking ${item.serviceTypeLabel.toLowerCase()} berhasil dibatalkan.')),
      );
      await _loadSchedules();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _cancellingId = null);
    }
  }

  Future<void> _rescheduleBooking(AppScheduleItem item) async {
    if (!item.canReschedule) return;

    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => RescheduleScreen(item: item)),
    );

    if (changed == true) {
      await _loadSchedules();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = AuthService().isLoggedIn;

    return Column(
      children: [
        _buildHeader(),
        const SizedBox(height: 16),
        _buildTabBar(),
        const SizedBox(height: 8),
        Expanded(
          child: !isLoggedIn
              ? _buildNeedLogin()
              : _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? _buildError()
                      : _buildScheduleList(),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          const UserAvatar(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SCHEDULE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textLight,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                    AuthService().isLoggedIn ? _displayName : 'Masuk untuk lihat jadwal',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _loadSchedules,
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildNeedLogin() {
    return _buildKosong(
      emojiWidget: Image.asset('assets/images/lock.png', width: 42, height: 42),
      judul: 'Login Dulu',
      deskripsi: 'Jadwal booking dokter, grooming, dan penitipan kamu akan muncul setelah login.',
      actionText: 'Login',
      onAction: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginScreen(redirectToProfile: false),
          ),
        ).then((_) => _loadSchedules());
      },
    );
  }

  Widget _buildError() {
    return _buildKosong(
      emojiWidget: Image.asset('assets/images/warning.png', width: 42, height: 42),
      judul: 'Gagal Memuat Jadwal',
      deskripsi: _error ?? 'Terjadi kesalahan saat memuat jadwal.',
      actionText: 'Coba Lagi',
      onAction: _loadSchedules,
    );
  }

  Widget _buildScheduleList() {
    final items = _filteredItems;

    if (items.isEmpty) {
      return _buildKosong(
        emojiWidget: Image.asset(
          _selectedTab == 0 ? 'assets/images/calendar.png' : 'assets/images/history.png',
          width: 42,
          height: 42,
        ),
        judul: _selectedTab == 0 ? 'Belum Ada Jadwal Mendatang' : 'Belum Ada Riwayat',
        deskripsi: _selectedTab == 0
            ? 'Booking dokter, grooming, dan penitipan yang masih aktif akan muncul di sini.'
            : 'Booking yang selesai atau batal akan muncul di sini.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSchedules,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = items[index];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (index == 0 || items[index - 1].date != item.date) ...[
                _buildDateLabel(_dateLabel(item.date)),
                const SizedBox(height: 10),
              ],
              _buildScheduleCard(item),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.categoryBg1,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            _buildTab('Mendatang', 0),
            _buildTab('Riwayat', 1),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final selected = _selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: selected ? AppColors.textDark : AppColors.textLight,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKosong({
    required Widget emojiWidget,
    required String judul,
    required String deskripsi,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                color: AppColors.categoryBg1,
                shape: BoxShape.circle,
              ),
              child: Center(child: emojiWidget),
            ),
            const SizedBox(height: 20),
            Text(
              judul,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              deskripsi,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textLight,
                height: 1.6,
              ),
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionText),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDateLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textLight,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildScheduleCard(AppScheduleItem item) {
    final statusColor = _statusColor(item.status);
    final isCancelling = _cancellingId == item.id;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => _showDetail(item),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.categoryBg1,
                  ),
                  child: Center(
                    child: Text(item.emoji, style: const TextStyle(fontSize: 26)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusLabel(item.status),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textLight),
                const SizedBox(width: 6),
                Text(
                  item.date,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMedium,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.access_time_outlined, size: 14, color: AppColors.textLight),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.time,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textMedium,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
              ],
            ),
            if (item.canCancel || item.canReschedule) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (item.canReschedule) ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _rescheduleBooking(item),
                        icon: const Icon(Icons.edit_calendar_rounded, size: 18),
                        label: const Text('Ubah Jadwal'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    if (item.canCancel) const SizedBox(width: 10),
                  ],
                  if (item.canCancel)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: isCancelling ? null : () => _cancelBooking(item),
                        icon: isCancelling
                            ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.cancel_outlined, size: 18),
                        label: Text(isCancelling ? 'Batal...' : 'Batalkan'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFE57373),
                          side: const BorderSide(color: Color(0xFFE57373)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ScheduleDetailSheet extends StatelessWidget {
  final AppScheduleItem item;
  final Color statusColor;
  final String statusLabel;
  final VoidCallback? onCancel;
  final VoidCallback? onReschedule;
  final bool cancelling;

  const _ScheduleDetailSheet({
    required this.item,
    required this.statusColor,
    required this.statusLabel,
    required this.onCancel,
    required this.onReschedule,
    required this.cancelling,
  });

  @override
  Widget build(BuildContext context) {
    final raw = item.raw;
    final extraRows = <_DetailRowData>[
      _DetailRowData(item.detailDateLabel, item.date),
      _DetailRowData('Waktu', item.time),
      _DetailRowData('Estimasi biaya', item.priceLabel),
      if (item.type == 'boarding') _DetailRowData('Rencana check-out', raw['tanggal_rencana_keluar']?.toString() ?? '-'),
      if (item.type == 'boarding') _DetailRowData('Durasi', '${raw['jumlah_hari'] ?? '-'} hari'),
      if (item.type == 'doctor') _DetailRowData('Dokter', raw['nama_dokter']?.toString() ?? '-'),
      if (item.type == 'doctor') _DetailRowData('Keluhan', raw['keluhan']?.toString() ?? '-'),
      if (item.type == 'grooming') _DetailRowData('Catatan', raw['catatan_grooming']?.toString() ?? '-'),
      if (item.type == 'boarding') _DetailRowData('Catatan', raw['catatan_titip']?.toString() ?? raw['catatan']?.toString() ?? '-'),
    ];

    return Container(
      margin: const EdgeInsets.only(top: 80),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.categoryBg1),
                    child: Center(child: Text(item.emoji, style: const TextStyle(fontSize: 28))),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textDark)),
                        const SizedBox(height: 4),
                        Text(item.subtitle, style: const TextStyle(fontSize: 13, color: AppColors.textLight)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(999)),
                child: Text(statusLabel, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: statusColor)),
              ),
              const SizedBox(height: 18),
              ...extraRows.map((row) => _detailRow(row.label, row.value)),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.accentLight, borderRadius: BorderRadius.circular(16)),
                child: Text(item.paymentNote, style: const TextStyle(fontSize: 12, color: AppColors.textMedium, height: 1.5)),
              ),
              if (onReschedule != null) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onReschedule,
                    icon: const Icon(Icons.edit_calendar_rounded, size: 18),
                    label: const Text('Ubah Jadwal'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
              if (onCancel != null) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: cancelling ? null : onCancel,
                    icon: cancelling
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.cancel_outlined, size: 18),
                    label: Text(cancelling ? 'Membatalkan...' : 'Batalkan Booking'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFE57373),
                      side: const BorderSide(color: Color(0xFFE57373)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    final safeValue = value.trim().isEmpty ? '-' : value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 130, child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textLight, fontWeight: FontWeight.w700))),
          Expanded(child: Text(safeValue, style: const TextStyle(fontSize: 13, color: AppColors.textDark, fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }
}

class _DetailRowData {
  final String label;
  final String value;

  _DetailRowData(this.label, this.value);
}