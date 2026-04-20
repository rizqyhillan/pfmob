import 'package:flutter/material.dart';
import '../theme/tema_app.dart';
import '../services/servis_auth.dart';
import 'profile.dart';
import 'login.dart';

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

  final List<_Product> _bestSellers = [
    _Product(
      name: 'Harvest Organic\nPet Food',
      price: 24.99,
      emoji: '🌿',
      bgColor: const Color(0xFFFFF3E8),
    ),
    _Product(
      name: 'Eco-Tug\nRope Toy',
      price: 12.50,
      emoji: '🧶',
      bgColor: const Color(0xFFE8F5F3),
    ),
    _Product(
      name: 'Pet Vitamin\nDrops',
      price: 18.00,
      emoji: '💊',
      bgColor: const Color(0xFFE8F4FF),
    ),
    _Product(
      name: 'Grooming\nBrush Set',
      price: 32.00,
      emoji: '🪮',
      bgColor: const Color(0xFFF3F0FF),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
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
                    childAspectRatio: 0.78,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2),
              color: AppColors.primaryLight,
            ),
            child: const ClipOval(
              child: Center(
                child: Text('🐱', style: TextStyle(fontSize: 22)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'OWNER',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textLight,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                'Kayla Nadine',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Notification bell
          Container(
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
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_outlined,
                    color: AppColors.textDark, size: 22),
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE57373),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          decoration: const InputDecoration(
            hintText: 'Search',
            prefixIcon:
                Icon(Icons.search, color: AppColors.textLight, size: 22),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6B4226), Color(0xFF9B6B3A)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              right: 100,
              top: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),
            Positioned(
              right: 60,
              bottom: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Treat Your\nBest Friend\nto 20% Off',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Organic grooming\nservices all week.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 7),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Claim Now',
                            style: TextStyle(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Dog emoji / illustration
                  const Text('🐕', style: TextStyle(fontSize: 72)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories() {
    final categories = [
      _Category('Belanja', Icons.shopping_bag_outlined, AppColors.categoryBg1,
          AppColors.primary),
      _Category('Booking', Icons.medical_services_outlined,
          AppColors.categoryBg2, const Color(0xFF2196F3)),
      _Category(
          'Hewan Saya', Icons.pets, AppColors.categoryBg3, AppColors.accent),
      _Category('Jadwal', Icons.calendar_today_outlined, AppColors.categoryBg4,
          const Color(0xFF7C4DFF)),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: categories.map((cat) => _buildCategoryItem(cat)).toList(),
      ),
    );
  }

  Widget _buildCategoryItem(_Category cat) {
    return Column(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: cat.bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cat.bgColor.withOpacity(0.5)),
          ),
          child: Icon(cat.icon, color: cat.iconColor, size: 26),
        ),
        const SizedBox(height: 6),
        Text(
          cat.label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildBestSellersHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Best Sellers',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'EXPLORE SHOP',
              style: TextStyle(
                color: AppColors.gold,
                fontWeight: FontWeight.w700,
                fontSize: 12,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(_Product product) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image Area
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: product.bgColor,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(18)),
                  ),
                  child: Center(
                    child: Text(
                      product.emoji,
                      style: const TextStyle(fontSize: 56),
                    ),
                  ),
                ),
                // Wishlist button
                Positioned(
                  top: 8,
                  right: 10,
                  child: Icon(
                    Icons.favorite_border,
                    color: AppColors.textLight,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          // Product Info
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                    height: 1.3,
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child:
                          const Icon(Icons.add, color: Colors.white, size: 18),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
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
                    // Cek apakah sudah login
                    if (AuthService().isLoggedIn) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ProfileScreen()),
                      );
                    } else {
                      // Belum login → ke halaman login
                      // Setelah login berhasil, langsung buka profile
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LoginScreen(
                            redirectToProfile: true,
                          ),
                        ),
                      );
                    }
                  } else {
                    setState(() => _currentIndex = i);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: _currentIndex == i
                        ? AppColors.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        items[i].icon,
                        color: _currentIndex == i
                            ? Colors.white
                            : AppColors.textLight,
                        size: 22,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        items[i].label,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: _currentIndex == i
                              ? Colors.white
                              : AppColors.textLight,
                          letterSpacing: 0.3,
                        ),
                      ),
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
  final String emoji;
  final Color bgColor;
  const _Product(
      {required this.name,
      required this.price,
      required this.emoji,
      required this.bgColor});
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
