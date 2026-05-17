import 'package:flutter/material.dart';
import '../../theme/tema_app.dart';
import '../../services/servis_auth.dart';
import '../../models/best_seller_product.dart';
import '../../services/best_seller_service.dart';
import '../../services/mock_best_seller_service.dart';
import '../login.dart';
import '../Shop/shop.dart';
import '../Booking/booking.dart';
import '../Schedule/schedule.dart';
import '../profile/my_pets.dart';
import '../Shop/keranjang.dart';
import '../Shop/detail_produk.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DashboardScreen extends StatefulWidget {
  final int initialIndex;
  const DashboardScreen({super.key, this.initialIndex = 0});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  final PageController _bannerController = PageController();
  int _currentBanner = 0;

  // ─── Best Seller state ──────────────────────────────────────
  /// Service abstraction — swap MockBestSellerService with a real
  /// API implementation when the backend endpoint is ready.
  final BestSellerService _bestSellerService = MockBestSellerService();

  List<BestSellerProduct> _bestSellers = [];
  bool _isBestSellersLoading = true;
  String? _bestSellersError;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
    _loadBestSellers();
  }

  @override
  void dispose() {
    _animController.dispose();
    _bannerController.dispose();
    super.dispose();
  }

  // ─── Async data loading ─────────────────────────────────────
  Future<void> _loadBestSellers() async {
    setState(() {
      _isBestSellersLoading = true;
      _bestSellersError = null;
    });

    try {
      final products = await _bestSellerService.getBestSellers();
      if (mounted) {
        setState(() {
          _bestSellers = products;
          _isBestSellersLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _bestSellersError = e.toString().replaceFirst('Exception: ', '');
          _isBestSellersLoading = false;
        });
      }
    }
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0: return _buildHomeContent();
      case 1: return const ShopContent();
      case 2: return const BookingContent();
      case 3: return const ScheduleContent();
      case 4: return const MyPetsScreen();
      default: return _buildHomeContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 251, 251, 251),
      body: SafeArea(child: _buildBody()),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHomeContent() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader()),
          SliverToBoxAdapter(child: _buildBanner()),
          SliverToBoxAdapter(child: _buildCategories()),
          SliverToBoxAdapter(child: _buildBestSellersHeader()),
          _buildBestSellersContent(),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  // ─── Best Sellers content with loading/error/empty states ───
  Widget _buildBestSellersContent() {
    // Loading state
    if (_isBestSellersLoading) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverGrid(
          delegate: SliverChildBuilderDelegate(
            (ctx, i) => _buildShimmerCard(),
            childCount: 4,
          ),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.70,
          ),
        ),
      );
    }

    // Error state
    if (_bestSellersError != null) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.divider),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
            ),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE8E8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.wifi_off_rounded, color: Color(0xFFE57373), size: 28),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Gagal Memuat Produk',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark),
                ),
                const SizedBox(height: 6),
                Text(
                  _bestSellersError!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: AppColors.textLight, height: 1.4),
                ),
                const SizedBox(height: 18),
                GestureDetector(
                  onTap: _loadBestSellers,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Coba Lagi',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Empty state
    if (_bestSellers.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.divider),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
            ),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.categoryBg1,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.inventory_2_outlined, color: AppColors.primary, size: 28),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Belum Ada Produk',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Produk best seller belum tersedia saat ini.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppColors.textLight, height: 1.4),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Data loaded — original grid layout preserved
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (ctx, i) => GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DetailProdukScreen(
                  nama: _bestSellers[i].name,
                  harga: _bestSellers[i].price,
                  image: _bestSellers[i].imageUrl,
                  bgColor: _bestSellers[i].bgColor,
                  pilihanjenis: const [],
                  deskripsi: '',
                ),
              ),
            ),
            child: _buildProductCard(_bestSellers[i]),
          ),
          childCount: _bestSellers.length,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.70,
        ),
      ),
    );
  }

  // ─── Shimmer/loading skeleton card ──────────────────────────
  Widget _buildShimmerCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.divider.withOpacity(0.5),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary.withOpacity(0.4)),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 50,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 60,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Container(
                      width: 30, height: 30,
                      decoration: BoxDecoration(color: AppColors.divider, shape: BoxShape.circle),
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

  Widget _buildHeader() {
    final auth = AuthService();
    final isLoggedIn = auth.isLoggedIn;
    final displayName = auth.userName.trim().isNotEmpty
        ? auth.userName.trim()
        : 'User PawPet';
  
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
              color: Colors.white,
            ),
            child: ClipOval(
              child: isLoggedIn
                  ? const Center(
                      child: Icon(
                        Icons.person_rounded,
                        color: AppColors.primary,
                        size: 26,
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(6),
                      child: SvgPicture.asset(
                        'assets/images/PawPetlogo.svg',
                        fit: BoxFit.contain,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLoggedIn ? 'OWNER' : 'WELCOME',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textLight,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  isLoggedIn ? displayName : 'PawPet',
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
          GestureDetector(
            onTap: () {
              if (AuthService().isLoggedIn) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const KeranjangScreen()),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(redirectToProfile: false),
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.divider),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                color: AppColors.textDark,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: const TextField(
          decoration: InputDecoration(
            hintText: 'Search',
            prefixIcon: Icon(Icons.search, color: AppColors.textLight, size: 22),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildBanner() {
    final banners = [
      'assets/images/iklan1.jpg',
      'assets/images/iklan2.jpg',
      'assets/images/iklan3.jpg',
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Column(
        children: [
          SizedBox(
            height: 140,
            child: PageView.builder(
              controller: _bannerController,
              onPageChanged: (i) => setState(() => _currentBanner = i % banners.length),
              itemCount: 999999,
              itemBuilder: (context, i) {
                final index = i % banners.length;
                return ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    banners[index],
                    width: double.infinity,
                    height: 140,
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(banners.length, (i) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentBanner == i ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentBanner == i ? AppColors.primary : AppColors.divider,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    final categories = [
      _Category('Shop', Icons.shopping_bag_outlined, AppColors.categoryBg1, AppColors.primary),
      _Category('Booking', Icons.medical_services_outlined, AppColors.categoryBg2, const Color(0xFF2196F3)),
      _Category('My Pets', Icons.pets, AppColors.categoryBg3, AppColors.accent),
      _Category('Schedule', Icons.calendar_today_outlined, AppColors.categoryBg4, const Color(0xFF7C4DFF)),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(categories.length, (i) {
          return GestureDetector(
            onTap: () {
              if (i == 0) setState(() => _currentIndex = 1);
              else if (i == 1) setState(() => _currentIndex = 2);
              else if (i == 2) setState(() => _currentIndex = 4);
              else if (i == 3) setState(() => _currentIndex = 3);
            },
            child: _buildCategoryItem(categories[i]),
          );
        }),
      ),
    );
  }

  Widget _buildCategoryItem(_Category cat) {
    return Column(
      children: [
        Container(
          width: 58, height: 58,
          decoration: BoxDecoration(
            color: cat.bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cat.bgColor.withOpacity(0.5)),
          ),
          child: Icon(cat.icon, color: cat.iconColor, size: 26),
        ),
        const SizedBox(height: 6),
        Text(cat.label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark)),
      ],
    );
  }

  Widget _buildBestSellersHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Best Sellers', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.textDark)),
          TextButton(
            onPressed: () => setState(() => _currentIndex = 1),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('EXPLORE SHOP', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700, fontSize: 12, letterSpacing: 0.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BestSellerProduct product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: product.bgColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                child: Image.asset(
                  product.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => Center(
                    child: Icon(Icons.image_not_supported_outlined, color: AppColors.textLight, size: 32),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark, height: 1.3),
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rp ${_formatHarga(product.price.toInt())}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textDark),
                    ),
                    Container(
                      width: 30, height: 30,
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      child: const Icon(Icons.add, color: Colors.white, size: 18),
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

  String _formatHarga(int harga) {
    return harga.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }

  Widget _buildBottomNav() {
    final items = [
      _NavItem(Icons.home_rounded, 'HOME'),
      _NavItem(Icons.storefront_outlined, 'SHOP'),
      _NavItem(Icons.calendar_month_outlined, 'BOOKING'),
      _NavItem(Icons.schedule_outlined, 'SCHEDULE'),
      _NavItem(Icons.pets_outlined, 'PROFILE'),
    ];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              items.length,
              (i) => GestureDetector(
                onTap: () {
                  if (i == 4) {
                    if (AuthService().isLoggedIn) {
                      setState(() => _currentIndex = 4);
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(redirectToProfile: false),
                        ),
                      );
                    }
                  } else {
                    setState(() => _currentIndex = i);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: _currentIndex == i ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(items[i].icon, color: _currentIndex == i ? Colors.white : AppColors.textLight, size: 22),
                      const SizedBox(height: 2),
                      Text(items[i].label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: _currentIndex == i ? Colors.white : AppColors.textLight, letterSpacing: 0.3)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Category {
  final String label;
  final IconData icon;
  final Color bgColor;
  final Color iconColor;
  const _Category(this.label, this.icon, this.bgColor, this.iconColor);
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}