import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/servis_auth.dart';
import '../../theme/tema_app.dart';
import '../login.dart';

class ScheduleContent extends StatefulWidget {
  const ScheduleContent({super.key});

  @override
  State<ScheduleContent> createState() => _ScheduleContentState();
}

class _ScheduleContentState extends State<ScheduleContent> {
  int _selectedTab = 0;
  bool _loading = false;
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
        ApiService.getMyBoardings(),
      ]);

      final merged = <AppScheduleItem>[
        ...results[0],
        ...results[1],
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
    final isLoggedIn = AuthService().isLoggedIn;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2),
              color: AppColors.primaryLight,
            ),
            child: Center(
              child: Text(
                isLoggedIn ? '🐾' : '📅',
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
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
                  isLoggedIn ? _displayName : 'Masuk untuk lihat jadwal',
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
      emoji: '🔐',
      judul: 'Login Dulu',
      deskripsi: 'Jadwal booking dokter dan penitipan kamu akan muncul setelah login.',
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
      emoji: '⚠️',
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
        emoji: _selectedTab == 0 ? '📅' : '🗂️',
        judul: _selectedTab == 0 ? 'Belum Ada Jadwal Mendatang' : 'Belum Ada Riwayat',
        deskripsi: _selectedTab == 0
            ? 'Booking dokter dan penitipan yang masih aktif akan muncul di sini.'
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
    required String emoji,
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
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 42)),
              ),
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

    return Container(
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
              Text(
                item.time,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMedium,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}