import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../viewmodels/booking_viewmodel.dart';
import '../../theme/tema_app.dart';
import '../../viewmodels/auth_viewmodel.dart';
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

  String _formatHarga(num harga) {
    return harga.round().toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
  }

  Future<void> _loadRooms() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final rooms = await context.read<BookingViewModel>().loadBoardingRooms();

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

  List<String> get _paketList {
    final paketSet = _rooms
        .map((room) => room.paket.trim())
        .where((paket) => paket.isNotEmpty && paket != '-')
        .toSet()
        .toList();

    paketSet.sort((a, b) {
      final order = ['basic', 'regular', 'premium'];
      final ai = order.indexOf(a.toLowerCase());
      final bi = order.indexOf(b.toLowerCase());

      if (ai == -1 && bi == -1) return a.compareTo(b);
      if (ai == -1) return 1;
      if (bi == -1) return -1;
      return ai.compareTo(bi);
    });

    return paketSet;
  }

  List<BoardingRoom> _roomsByPaket(String paket) {
    return _rooms
        .where((room) => room.paket.toLowerCase() == paket.toLowerCase())
        .toList();
  }

  double _lowestPriceByPaket(String paket) {
    final rooms = _roomsByPaket(paket);
    if (rooms.isEmpty) return 0;

    rooms.sort((a, b) => a.hargaPerHari.compareTo(b.hargaPerHari));
    return rooms.first.hargaPerHari;
  }

  int _availableRoomCount(String paket) {
    return _roomsByPaket(paket).where((room) => room.tersedia).length;
  }

  int _totalRoomCount(String paket) {
    return _roomsByPaket(paket).length;
  }

  List<String> _fasilitasPreview(String paket) {
    final allFacilities = <String>{};

    for (final room in _roomsByPaket(paket)) {
      allFacilities.addAll(room.fasilitas);
    }

    return allFacilities.take(4).toList();
  }

  Color _paketColor(String paket) {
    switch (paket.toLowerCase()) {
      case 'basic':
        return const Color(0xFF4A9B8E);
      case 'regular':
        return const Color(0xFF2196F3);
      case 'premium':
        return const Color(0xFFFF9800);
      default:
        return AppColors.primary;
    }
  }

  Color _paketBgColor(String paket) {
    switch (paket.toLowerCase()) {
      case 'basic':
        return const Color(0xFFE0F5F2);
      case 'regular':
        return const Color(0xFFE3F2FD);
      case 'premium':
        return const Color(0xFFFFF3E0);
      default:
        return AppColors.categoryBg1;
    }
  }

  IconData _paketIcon(String paket) {
    switch (paket.toLowerCase()) {
      case 'basic':
        return Icons.home_rounded;
      case 'regular':
        return Icons.apartment_rounded;
      case 'premium':
        return Icons.king_bed_rounded;
      default:
        return Icons.meeting_room_rounded;
    }
  }

  String _paketDescription(String paket) {
    switch (paket.toLowerCase()) {
      case 'basic':
        return 'Pilihan hemat untuk penitipan harian';
      case 'regular':
        return 'Paket nyaman dengan fasilitas lebih lengkap';
      case 'premium':
        return 'Paket terbaik untuk kenyamanan maksimal';
      default:
        return 'Pilih kamar penitipan sesuai kebutuhan';
    }
  }


  Widget _roomImage(BoardingRoom room, Color warna) {
    return _RoomImageCarousel(
      room: room,
      warna: warna,
    );
  }

  void _openBoardingConfirmation(BoardingRoom room) {
    if (!room.tersedia) return;

    if (!context.read<AuthViewModel>().isLoggedIn) {
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

  void _showRoomBottomSheet(String paket) {
    final rooms = _roomsByPaket(paket);
    final warna = _paketColor(paket);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.72,
          minChildSize: 0.45,
          maxChildSize: 0.92,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _paketBgColor(paket),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(_paketIcon(paket), color: warna),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kamar Paket $paket',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${_availableRoomCount(paket)} dari ${_totalRoomCount(paket)} kamar tersedia',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.categoryBg1,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: AppColors.textMedium,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      itemCount: rooms.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, index) => _roomCard(rooms[index], warna),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            const SizedBox(height: 16),
            const Text(
              'Paket Penitipan',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Pilih paket penitipan, lalu pilih kamar yang tersedia',
              style: TextStyle(fontSize: 13, color: AppColors.textLight),
            ),
          ],
        ),
      );

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_error != null) {
      return _message('⚠️', _error!, 'Coba Lagi', _loadRooms);
    }

    if (_rooms.isEmpty || _paketList.isEmpty) {
      return _message(
        '🏠',
        'Belum ada paket penitipan tersedia',
        'Muat Ulang',
        _loadRooms,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRooms,
      color: AppColors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        itemCount: _paketList.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (_, index) {
          final paket = _paketList[index];
          return _paketCard(paket);
        },
      ),
    );
  }

  Widget _message(
    String icon,
    String title,
    String action,
    VoidCallback onAction,
  ) {
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
            ElevatedButton(
              onPressed: onAction,
              child: Text(action),
            ),
          ],
        ),
      ),
    );
  }

  Widget _paketCard(String paket) {
    final warna = _paketColor(paket);
    final bgColor = _paketBgColor(paket);
    final lowestPrice = _lowestPriceByPaket(paket);
    final availableCount = _availableRoomCount(paket);
    final totalCount = _totalRoomCount(paket);
    final fasilitas = _fasilitasPreview(paket);
    final isFavorit = paket.toLowerCase() == 'regular';

    return GestureDetector(
      onTap: () => _showRoomBottomSheet(paket),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isFavorit ? warna : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(_paketIcon(paket), color: warna, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'Paket $paket',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: warna,
                              ),
                            ),
                          ),
                          if (isFavorit) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: warna,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Favorit',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _paketDescription(paket),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Mulai dari',
                      style: TextStyle(
                        fontSize: 10,
                        color: warna.withValues(alpha: 0.75),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Rp ${_formatHarga(lowestPrice)}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: warna,
                      ),
                    ),
                    Text(
                      '/ hari',
                      style: TextStyle(
                        fontSize: 10,
                        color: warna.withValues(alpha: 0.75),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.meeting_room_rounded, color: warna, size: 16),
                const SizedBox(width: 8),
                Text(
                  '$availableCount dari $totalCount kamar tersedia',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMedium,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            if (fasilitas.isNotEmpty) ...[
              const SizedBox(height: 10),
              ...fasilitas.map(
                (f) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_rounded, color: warna, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          f,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: warna,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Lihat Kamar Tersedia',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roomCard(BoardingRoom room, Color warna) {
    final isAvailable = room.tersedia;

    return GestureDetector(
      onTap: isAvailable ? () => _openBoardingConfirmation(room) : null,
      child: Opacity(
        opacity: isAvailable ? 1 : 0.55,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.divider),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 150,
                width: double.infinity,
                child: _roomImage(room, warna),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: warna.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      Icons.bedroom_parent_rounded,
                      color: warna,
                      size: 23,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          room.namaKamar,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Rp ${_formatHarga(room.hargaPerHari)} / hari',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: warna,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isAvailable
                        ? Icons.chevron_right_rounded
                        : Icons.lock_rounded,
                    color: AppColors.textLight,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: isAvailable
                      ? warna.withValues(alpha: 0.10)
                      : Colors.grey.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isAvailable
                      ? 'Kapasitas tersisa: ${room.sisaKapasitas}/${room.kapasitas}'
                      : 'Kamar penuh / tidak tersedia',
                  style: TextStyle(
                    fontSize: 12,
                    color: isAvailable ? warna : AppColors.textLight,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (room.fasilitas.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: room.fasilitas
                      .take(5)
                      .map(
                        (f) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accentLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            f,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.accent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RoomImageCarousel extends StatefulWidget {
  final BoardingRoom room;
  final Color warna;
  const _RoomImageCarousel({
    required this.room,
    required this.warna,
  });

  @override
  State<_RoomImageCarousel> createState() => _RoomImageCarouselState();
}

class _RoomImageCarouselState extends State<_RoomImageCarousel> {
  late final PageController _pageController;
  int _activeIndex = 0;

  List<String> get _photos => widget.room.fotoUrls;
  bool get _hasMultiplePhotos => _photos.length > 1;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _emptyPhotoPlaceholder({
    required IconData icon,
    required String title,
  }) {
    return Container(
      color: widget.warna.withValues(alpha: 0.10),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: widget.warna,
              size: 34,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: widget.warna,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _networkImage(String url) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _emptyPhotoPlaceholder(
        icon: Icons.broken_image_rounded,
        title: 'Foto gagal dimuat',
      ),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;

        return Container(
          color: widget.warna.withValues(alpha: 0.10),
          child: Center(
            child: CircularProgressIndicator(
              color: widget.warna,
              strokeWidth: 2,
            ),
          ),
        );
      },
    );
  }

  Widget _imageContent() {
    if (_photos.isEmpty) {
      return _emptyPhotoPlaceholder(
        icon: Icons.image_not_supported_rounded,
        title: 'Belum ada foto kamar',
      );
    }

    if (_photos.length == 1) {
      return _networkImage(_photos.first);
    }

    return PageView.builder(
      controller: _pageController,
      physics: const PageScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      itemCount: _photos.length,
      onPageChanged: (index) {
        setState(() => _activeIndex = index);
      },
      itemBuilder: (context, index) => _networkImage(_photos[index]),
    );
  }

  void _openPhotoPreview() {
    if (_photos.isEmpty) return;

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.88),
      builder: (_) => _RoomPhotoPreviewDialog(
        photos: _photos,
        initialIndex: _activeIndex.clamp(0, _photos.length - 1),
        roomName: widget.room.namaKamar,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final room = widget.room;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _photos.isEmpty ? null : _openPhotoPreview,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
          _imageContent(),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.08),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.48),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_hasMultiplePhotos)
            Positioned(
              top: 10,
              right: 10,
              child: IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.42),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.photo_library_rounded,
                        color: Colors.white,
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_activeIndex + 1}/${_photos.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 10,
            child: IgnorePointer(
              child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Paket ${room.paket}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: widget.warna,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: room.tersedia
                            ? widget.warna.withValues(alpha: 0.92)
                            : Colors.grey.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        room.tersedia ? 'Tersedia' : 'Penuh',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                if (_hasMultiplePhotos) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _photos.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        margin: const EdgeInsets.symmetric(horizontal: 2.5),
                        width: _activeIndex == index ? 14 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _activeIndex == index
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }
}


class _RoomPhotoPreviewDialog extends StatefulWidget {
  final List<String> photos;
  final int initialIndex;
  final String roomName;

  const _RoomPhotoPreviewDialog({
    required this.photos,
    required this.initialIndex,
    required this.roomName,
  });

  @override
  State<_RoomPhotoPreviewDialog> createState() =>
      _RoomPhotoPreviewDialogState();
}

class _RoomPhotoPreviewDialogState extends State<_RoomPhotoPreviewDialog> {
  late final PageController _previewController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _previewController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _previewController.dispose();
    super.dispose();
  }

  Widget _previewImage(String url) {
    return InteractiveViewer(
      minScale: 1,
      maxScale: 4,
      child: Center(
        child: Image.network(
          url,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.broken_image_rounded,
                color: Colors.white,
                size: 46,
              ),
              SizedBox(height: 10),
              Text(
                'Foto gagal dimuat',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;

            return const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final hasMultiplePhotos = widget.photos.length > 1;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      backgroundColor: Colors.transparent,
      child: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: size.width - 28,
            maxHeight: size.height * 0.86,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Material(
              color: Colors.black,
              child: Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: size.height * 0.78,
                    child: PageView.builder(
                      controller: _previewController,
                      physics: const PageScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      itemCount: widget.photos.length,
                      onPageChanged: (index) {
                        setState(() => _currentIndex = index);
                      },
                      itemBuilder: (context, index) =>
                          _previewImage(widget.photos[index]),
                    ),
                  ),
                  Positioned(
                    left: 14,
                    right: 56,
                    top: 12,
                    child: IgnorePointer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.roomName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          if (hasMultiplePhotos) ...[
                            const SizedBox(height: 3),
                            Text(
                              '${_currentIndex + 1}/${widget.photos.length}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.82),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton.filled(
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black.withValues(alpha: 0.45),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ),
                  if (hasMultiplePhotos)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 14,
                      child: IgnorePointer(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            widget.photos.length,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 3),
                              width: _currentIndex == index ? 16 : 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: _currentIndex == index
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.48),
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
