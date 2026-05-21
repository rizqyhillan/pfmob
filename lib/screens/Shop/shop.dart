import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/servis_auth.dart';
import '../../theme/tema_app.dart';
import '../login.dart';
import '../profile/my_pets.dart';
import '../../widgets/user_avatar.dart';
import 'detail_produk.dart';
import 'keranjang.dart';

class ShopContent extends StatefulWidget {
  const ShopContent({super.key});

  @override
  State<ShopContent> createState() => _ShopContentState();
}

class _ShopContentState extends State<ShopContent> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _categories = ['Semua'];
  List<ShopProduct> _products = [];
  String _selectedCategory = 'Semua';
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
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

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        ApiService.getShopCategories(),
        ApiService.getShopProducts(
          search: _searchController.text,
          kategori: _selectedCategory == 'Semua' ? null : _selectedCategory,
        ),
      ]);

      if (!mounted) return;
      setState(() {
        _categories = ['Semua', ...(results[0] as List<String>)];
        _products = results[1] as List<ShopProduct>;
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

    void _openCart() {
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
      ],
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
          const UserAvatar(),
          const SizedBox(width: 12),
          Column(
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
          const Spacer(),
          GestureDetector(
            onTap: _openCart,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.divider),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: const Icon(Icons.shopping_cart_outlined, color: AppColors.textDark, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => _loadData(),
        decoration: InputDecoration(
          hintText: 'Cari produk',
          prefixIcon: const Icon(Icons.search, color: AppColors.textLight, size: 22),
          suffixIcon: IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadData,
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
      return _MessageState(icon: '⚠️', title: _error!, actionText: 'Coba Lagi', onAction: _loadData);
    }
    if (_products.isEmpty) return _MessageState(icon: '🛒', title: 'Produk belum tersedia', actionText: 'Muat ulang', onAction: _loadData);

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

  Widget _buildProductCard(ShopProduct product) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailProdukScreen(productId: product.id))),
      child: Container(
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
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.categoryBg1, borderRadius: BorderRadius.circular(14)),
                child: product.imageUrl != null
                    ? ClipRRect(borderRadius: BorderRadius.circular(14), child: Image.network(product.imageUrl!, fit: BoxFit.cover))
                    : const Center(child: Image(image: AssetImage('assets/images/logo-paw.png')))
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.namaBarang, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                  const SizedBox(height: 4),
                  Text(product.kategori, style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
                  const SizedBox(height: 6),
                  Text('Rp ${_formatHarga(product.harga)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary)),
                  Text('Stok ${product.stok}', style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
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
  final String icon;
  final String title;
  final String actionText;
  final VoidCallback onAction;

  const _MessageState({required this.icon, required this.title, required this.actionText, required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 48)),
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
