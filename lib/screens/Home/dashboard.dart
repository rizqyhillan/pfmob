import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/tema_app.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../models/product.dart';
import '../../models/home_banner.dart';
import '../../services/api_service.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../login.dart';
import '../Shop/shop.dart';
import '../Booking/booking.dart';
import '../Schedule/schedule.dart';
import '../profile/my_pets.dart';
import '../Shop/keranjang.dart';
import '../Shop/detail_produk.dart';
import '../../widgets/user_avatar.dart';
import '../profile/profile.dart';

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
  List<HomeBanner> _homeBanners = const [];
  bool _isHomeBannersLoading = true;

  // ─── Best Seller state ──────────────────────────────────────
  List<Product> _bestSellers = [];
  bool _isBestSellersLoading = true;
  String? _bestSellersError;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadHomeBanners();
      _loadBestSellers();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _bannerController.dispose();
    super.dispose();
  }

  // ─── Async data loading ─────────────────────────────────────
  Future<void> _loadHomeBanners() async {
    try {
      final banners = await ApiService.getHomeBanners();
      if (!mounted) return;

      setState(() {
        _homeBanners = banners.where((banner) => banner.imageUrl.isNotEmpty).toList();
        _isHomeBannersLoading = false;
        _currentBanner = 0;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _homeBanners = const [];
        _isHomeBannersLoading = false;
        _currentBanner = 0;
      });
    }
  }

  Future<void> _loadBestSellers() async {
    if (!mounted) return;
    setState(() {
      _isBestSellersLoading = true;
      _bestSellersError = null;
    });

    try {
      final products = await context.read<HomeViewModel>().loadBestSellers();
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
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3))],
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
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3))],
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
                  productId: _bestSellers[i].id,
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
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.divider.withValues(alpha: 0.5),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary.withValues(alpha: 0.4)),
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
    final authViewModel = context.watch<AuthViewModel>();
    final isLoggedIn = authViewModel.isLoggedIn;
    final displayName = authViewModel.userName.trim().isNotEmpty
        ? authViewModel.userName.trim()
        : 'User PawPet';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (context.read<AuthViewModel>().isLoggedIn) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProfileScreen(showBackButton: true),
                  ),
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
            child: const UserAvatar(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLoggedIn ? 'PET OWNER' : 'WELCOME',
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
              if (context.read<AuthViewModel>().isLoggedIn) {
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
                    color: Colors.black.withValues(alpha: 0.04),
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
  Widget _buildBanner() {
    const fallbackBanners = [
      'assets/images/iklan1.jpg',
      'assets/images/iklan2.jpg',
      'assets/images/iklan3.jpg',
    ];

    final useDynamicBanners = !_isHomeBannersLoading && _homeBanners.isNotEmpty;
    final bannerCount = useDynamicBanners ? _homeBanners.length : fallbackBanners.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Column(
        children: [
          SizedBox(
            height: 140,
            child: PageView.builder(
              controller: _bannerController,
              onPageChanged: (i) => setState(() => _currentBanner = i % bannerCount),
              itemCount: bannerCount == 1 ? 1 : 999999,
              itemBuilder: (context, i) {
                final index = i % bannerCount;
                if (useDynamicBanners) {
                  return _buildDynamicBanner(_homeBanners[index]);
                }

                return ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    fallbackBanners[index],
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
            children: List.generate(bannerCount, (i) {
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

  Widget _buildDynamicBanner(HomeBanner banner) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            banner.imageUrl,
            width: double.infinity,
            height: 140,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Image.asset(
              'assets/images/iklan1.jpg',
              width: double.infinity,
              height: 140,
              fit: BoxFit.cover,
            ),
          ),
          if (banner.title.isNotEmpty || banner.subtitle.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.55),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (banner.title.isNotEmpty)
                      Text(
                        banner.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    if (banner.subtitle.isNotEmpty)
                      Text(
                        banner.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
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
              if (i == 0) { setState(() => _currentIndex = 1); }
              else if (i == 1) { setState(() => _currentIndex = 2); }
              else if (i == 2) { setState(() => _currentIndex = 4); }
              else if (i == 3) { setState(() => _currentIndex = 3); }
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
            border: Border.all(color: cat.bgColor.withValues(alpha: 0.5)),
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

  Widget _buildProductCard(Product product) {
    final url = product.imageUrl.trim();
    final isNetwork = url.startsWith('http://') || url.startsWith('https://');
    final hasImage = url.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3))],
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
                child: hasImage
                    ? (isNetwork
                        ? Image.network(
                            url,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (ctx, child, progress) {
                              if (progress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary.withValues(alpha: 0.3)),
                                ),
                              );
                            },
                            errorBuilder: (ctx, err, stack) => const Center(
                              child: Image(
                                  image: AssetImage('assets/images/logo-paw.png'),
                                  width: 48,
                                  height: 48,
                              ),
                            ),
                          )
                        : Image.asset(
                            url,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stack) => const Center(
                              child: Image(
                                  image: AssetImage('assets/images/logo-paw.png'),
                                  width: 48,
                                  height: 48,
                              ),
                            ),
                          ))
                    : const Center(
                        child: Image(
                          image: AssetImage('assets/images/logo-paw.png'),
                          width: 48,
                          height: 48,
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

  void changeTab(int index) {
    if (index == 4) {
      if (context.read<AuthViewModel>().isLoggedIn) {
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
      setState(() => _currentIndex = index);
    }
  }

  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 20,
          offset: const Offset(0, -4),
        ),
      ],
    ),
    child: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = constraints.maxWidth / items.length;
            const indicatorWidth = 66.0;
            const indicatorHeight = 52.0;

            return SizedBox(
              height: 58,
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 763),
                    curve: Curves.easeOutCubic,
                    left: (_currentIndex * itemWidth) +
                        ((itemWidth - indicatorWidth) / 2),
                    top: 3,
                    width: indicatorWidth,
                    height: indicatorHeight,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.28),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Row(
                    children: List.generate(
                      items.length,
                      (i) {
                        final selected = _currentIndex == i;

                        return SizedBox(
                          width: itemWidth,
                          height: 58,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => changeTab(i),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AnimatedScale(
                                  scale: selected ? 1.08 : 1.0,
                                  duration: const Duration(milliseconds: 220),
                                  curve: Curves.easeOut,
                                  child: Icon(
                                    items[i].icon,
                                    color: selected
                                        ? Colors.white
                                        : AppColors.textLight,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 220),
                                  curve: Curves.easeOut,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: selected
                                        ? Colors.white
                                        : AppColors.textLight,
                                    letterSpacing: 0.3,
                                  ),
                                  child: Text(items[i].label),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
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