import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../theme/tema_app.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/shop_viewmodel.dart';
import '../login.dart';
import '../../widgets/user_avatar.dart';
import 'detail_produk.dart';
import 'keranjang.dart';
import '../profile/profile.dart';

class ShopContent extends StatefulWidget {
  const ShopContent({super.key});

  @override
  State<ShopContent> createState() => _ShopContentState();
}

class _ShopContentState extends State<ShopContent> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _categories = ['Semua'];
  List<Product> _products = [];
  String _selectedCategory = 'Semua';
  bool _loading = true;
  String? _error;
  ShopCart? _cart;
  bool _showCartSummary = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadCart();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatHarga(num harga) {
    return harga.round().toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
  }

  Future<void> _loadData({bool forceRefresh = false}) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final shopViewModel = context.read<ShopViewModel>();
      await shopViewModel.loadProducts(
        search: _searchController.text,
        selectedCategory: _selectedCategory,
        forceRefresh: forceRefresh,
      );

      if (!mounted) return;
      setState(() {
        _categories = shopViewModel.categories;
        _products = shopViewModel.products;
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

  Future<void> _loadCart({bool forceRefresh = false}) async {
    final authViewModel = context.read<AuthViewModel>();
    final shopViewModel = context.read<ShopViewModel>();

    if (!authViewModel.isLoggedIn) {
      if (!mounted) return;
      setState(() {
        _cart = null;
        _showCartSummary = false;
      });
      return;
    }

    try {
      final cart = await shopViewModel.loadCart(silent: true, forceRefresh: forceRefresh);
      if (!mounted) return;
      setState(() {
        _cart = cart;
        _showCartSummary = cart?.items.isNotEmpty ?? false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _cart = null;
        _showCartSummary = false;
      });
    }
  }

  void _openCart() {
    final route = context.read<AuthViewModel>().isLoggedIn
        ? MaterialPageRoute(builder: (_) => const KeranjangScreen())
        : MaterialPageRoute(builder: (_) => const LoginScreen(redirectToProfile: false));

    Navigator.push(context, route).then((_) {
      // Reload cart summary after returning from cart or login flow.
      _loadCart(forceRefresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildSearchBar(),
        _buildCategories(),
        _buildTitle(),
        Expanded(child: _buildBody()),
        if (_showCartSummary) _buildCartSummaryBanner(),
      ],
    );
  }

  Widget _buildHeader() {
    return Selector<AuthViewModel, ({bool isLoggedIn, String userName})>(
      selector: (_, vm) => (
        isLoggedIn: vm.isLoggedIn,
        userName: vm.userName.trim(),
      ),
      builder: (context, authState, _) {
        final displayName = authState.userName.isNotEmpty ? authState.userName : 'User PawPet';
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
                  authState.isLoggedIn ? 'PET OWNER' : 'WELCOME',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textLight,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  authState.isLoggedIn ? displayName : 'PawPet',
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
            onTap: _openCart,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.divider),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: const Icon(Icons.shopping_cart_outlined, color: AppColors.textDark, size: 22),
            ),
          ),
        ],
      ),
    );
      },
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => _loadData(forceRefresh: true),
        decoration: InputDecoration(
          hintText: 'Cari produk',
          prefixIcon: const Icon(Icons.search, color: AppColors.textLight, size: 22),
          suffixIcon: IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => _loadData(forceRefresh: true),
          ),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 0, 0),
      child: SizedBox(
        height: 38,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, i) {
            final cat = _categories[i];
            final selected = _selectedCategory == cat;
            return GestureDetector(
              onTap: () {
                setState(() => _selectedCategory = cat);
                _loadData();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: selected ? AppColors.primary : AppColors.divider),
                ),
                child: Text(
                  cat,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? Colors.white : AppColors.textMedium),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 4),
      child: Row(
        children: [
          Text('Produk Tersedia', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.textDark)),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return _MessageState(image: const AssetImage('assets/images/warning.png'), title: _error!, actionText: 'Coba Lagi', onAction: _loadData);
    }
    if (_products.isEmpty) return _MessageState(image: const AssetImage('assets/images/shopping-cart.png'), title: 'Produk belum tersedia', actionText: 'Muat ulang', onAction: _loadData);

    return RefreshIndicator(
      onRefresh: _loadData,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        itemCount: _products.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.70,
        ),
        itemBuilder: (context, i) => _buildProductCard(_products[i]),
      ),
    );
  }

  Widget _buildCartSummaryBanner() {
    final cart = _cart;
    if (cart == null || cart.items.isEmpty) return const SizedBox.shrink();

    return GestureDetector(
      onTap: _openCart,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${cart.totalItem} produk',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Rp ${_formatHarga(cart.totalHarga)}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    final hasImage = product.imageUrl.isNotEmpty;
    return GestureDetector(
      onTap: () async {
        final updated = await Navigator.push<bool?>(
          context,
          MaterialPageRoute(builder: (_) => DetailProdukScreen(productId: product.id)),
        );
        if (updated == true) {
          await _loadCart(forceRefresh: true);
        }
      },
      child: Container(
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
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.categoryBg1, borderRadius: BorderRadius.circular(14)),
                child: hasImage
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(14), 
                        child: Image.network(
                          product.imageUrl, 
                          cacheWidth: 420,
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
                        ),
                      )
                    : const Center(child: Image(image: AssetImage('assets/images/logo-paw.png'), width: 48, height: 48))
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                  const SizedBox(height: 4),
                  Text(product.category, style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
                  const SizedBox(height: 6),
                  Text('Rp ${_formatHarga(product.price)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary)),
                  Text('Stok ${product.stock}', style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  final AssetImage image;
  final String title;
  final String actionText;
  final VoidCallback onAction;

  const _MessageState({required this.image, required this.title, required this.actionText, required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image(image: image, width: 48, height: 48),
            const SizedBox(height: 10),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textMedium, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onAction, child: Text(actionText)),
          ],
        ),
      ),
    );
  }
}
