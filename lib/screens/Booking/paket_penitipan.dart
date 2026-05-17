import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/servis_auth.dart';
import '../../theme/tema_app.dart';
import '../login.dart';
import 'konfirmasi_penitipan.dart';

class PaketPenitipanScreen extends StatefulWidget {
  const PaketPenitipanScreen({super.key});

  @override
  State<PaketPenitipanScreen> createState() => _PaketPenitipanScreenState();
}

class _PaketPenitipanScreenState extends State<PaketPenitipanScreen> {
  List<BoardingRoom> _rooms = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  String _formatHarga(num harga) => harga.round().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

  Future<void> _loadRooms() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rooms = await ApiService.getBoardingRooms();
      if (!mounted) return;
      setState(() {
        _rooms = rooms;
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

  void _openBoardingConfirmation(BoardingRoom room) {
    if (!room.tersedia) return;

    if (!AuthService().isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(redirectToProfile: false),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => KonfirmasiPenitipanScreen(room: room),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 8),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          GestureDetector(onTap: () => Navigator.pop(context), child: Container(width: 38, height: 38, decoration: BoxDecoration(color: AppColors.categoryBg1, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.primary))),
          const SizedBox(height: 16),
          const Text('Paket Penitipan', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textDark)),
          const SizedBox(height: 4),
          const Text('Pilih kamar aktif dari backend', style: TextStyle(fontSize: 13, color: AppColors.textLight)),
        ]),
      );

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return _message('⚠️', _error!, 'Coba Lagi', _loadRooms);
    if (_rooms.isEmpty) return _message('🏠', 'Belum ada kamar tersedia', 'Muat ulang', _loadRooms);
    return RefreshIndicator(
      onRefresh: _loadRooms,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        itemCount: _rooms.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _roomCard(_rooms[i]),
      ),
    );
  }

  Widget _message(String icon, String title, String action, VoidCallback onAction) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text(icon, style: const TextStyle(fontSize: 48)), const SizedBox(height: 12), Text(title, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textMedium, fontWeight: FontWeight.w700)), const SizedBox(height: 12), ElevatedButton(onPressed: onAction, child: Text(action))]));

  Widget _roomCard(BoardingRoom room) => GestureDetector(
        onTap: room.tersedia ? () => _openBoardingConfirmation(room) : null,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.divider)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 56, height: 56, decoration: BoxDecoration(color: AppColors.categoryBg1, borderRadius: BorderRadius.circular(14)), child: const Center(child: Text('🏠', style: TextStyle(fontSize: 28)))),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(room.namaKamar, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textDark)),
                const SizedBox(height: 3),
                Text(room.paket, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
                const SizedBox(height: 6),
                Text('Rp ${_formatHarga(room.hargaPerHari)} / hari', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primary)),
              ])),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
            ]),
            const SizedBox(height: 12),
            Text('Kapasitas tersisa: ${room.sisaKapasitas}/${room.kapasitas}', style: const TextStyle(fontSize: 12, color: AppColors.textMedium)),
            if (room.fasilitas.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(spacing: 6, runSpacing: 6, children: room.fasilitas.take(4).map((f) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: AppColors.accentLight, borderRadius: BorderRadius.circular(20)), child: Text(f, style: const TextStyle(fontSize: 11, color: AppColors.accent, fontWeight: FontWeight.w700)))).toList()),
            ],
          ]),
        ),
      );
}
