import 'package:flutter/material.dart';
import '../../theme/tema_app.dart';
import '../../services/servis_auth.dart';
import '../profile/profile.dart';
import '../login.dart';
import '../Shop/shop.dart';
import '../Booking/booking.dart';
import '../Schedule/schedule.dart';
import '../Booking/konfirmasi_grooming.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

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

  final List<_Product> _bestSellers = [
  _Product(name: 'Royal Canin\nKitten', price: 125000, image: 'assets/images/product1.jpg', bgColor: const Color(0xFFFFF3E8)),
  _Product(name: 'Me-O Creamy\nTreats', price: 35000, image: 'assets/images/product2.jpg', bgColor: const Color(0xFFE8F5F3)),
  _Product(name: 'Cat\nShampoo', price: 45000, image: 'assets/images/product3.jpg', bgColor: const Color(0xFFFFE8F0)),
  _Product(name: 'Salmon\nPowder', price: 89000, image: 'assets/images/product4.jpg', bgColor: const Color(0xFFE8F4FF)),
];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _bannerController.dispose();
    super.dispose();
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0: return _buildHomeContent();
      case 1: return const ShopContent();
      case 2: return const BookingContent();
      case 3: return const ScheduleContent();
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
          SliverToBoxAdapter(child: _buildSearchBar()),
          SliverToBoxAdapter(child: _buildBanner()),
          SliverToBoxAdapter(child: _buildCategories()),
          SliverToBoxAdapter(child: _buildBestSellersHeader()),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _buildProductCard(_bestSellers[i]),
                childCount: _bestSellers.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.70,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.primary, width: 2), color: AppColors.primaryLight),
            child: const ClipOval(child: Center(child: Text('🐱', style: TextStyle(fontSize: 22)))),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('OWNER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textLight, letterSpacing: 1.2)),
              Text('Kayla Nadine', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark)),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.divider),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_outlined, color: AppColors.textDark, size: 22),
                Positioned(top: -2, right: -2, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFE57373), shape: BoxShape.circle))),
              ],
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
          color: Colors.white, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: const TextField(
          decoration: InputDecoration(
            hintText: 'Search',
            prefixIcon: Icon(Icons.search, color: AppColors.textLight, size: 22),
            border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none,
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
          // Indikator bulat
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
          decoration: BoxDecoration(color: cat.bgColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: cat.bgColor.withOpacity(0.5))),
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
            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
            child: const Text('EXPLORE SHOP', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700, fontSize: 12, letterSpacing: 0.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(_Product product) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.divider),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: product.bgColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                ),
                child: product.image != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                        child: Image.asset(
                          product.image!,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Center(child: Text(product.emoji ?? '', style: const TextStyle(fontSize: 56))),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(product.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark, height: 1.3), maxLines: 2),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Rp ${_formatHarga(product.price.toInt())}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textDark)),
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
  return harga.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
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
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
                    } else {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen(redirectToProfile: true)));
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

class _Product {
  final String name;
  final double price;
  final String? emoji;
  final String? image;
  final Color bgColor;
  const _Product({required this.name, required this.price, this.emoji, this.image, required this.bgColor});
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