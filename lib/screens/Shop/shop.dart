import 'package:flutter/material.dart';
import '../../theme/tema_app.dart';
import 'keranjang.dart';

class ShopContent extends StatefulWidget {
  const ShopContent({super.key});

  @override
  State<ShopContent> createState() => _ShopContentState();
}

class _ShopContentState extends State<ShopContent> {
  int _selectedCategory = 0;
  final List<String> _categories = ['All Products', 'Food', 'Grooming', 'Vitamins', 'Fashion', 'Accessories'];

  final List<_ShopProduct> _products = [
    _ShopProduct(name: 'Collapsible Bowl', price: 185000, image: 'assets/images/product5.jpg', bgColor: Color(0xFFFFF3E8), kategori: 'Accessories'), 
    _ShopProduct(name: 'Pet Carrier Bag', price: 95000, image: 'assets/images/product6.jpg', bgColor: Color(0xFFE8F4FF), kategori: 'Accessories'),
    _ShopProduct(name: 'Paw Balm', price: 45000, image: 'assets/images/product7.jpg', bgColor: Color(0xFFE8F5F3), kategori: 'Grooming'),
    _ShopProduct(name: 'Ear Finger Wipes', price: 55000, image: 'assets/images/product8.jpg', bgColor: Color(0xFFFFE8F0), kategori: 'Grooming'),
    _ShopProduct(name: 'Pet Hoodie Costume', price: 250000, image: 'assets/images/product9.jpg', bgColor: Color(0xFFE8F5F3), kategori: 'Fashion'),
    _ShopProduct(name: 'Steam Grooming Brush', price: 35000, image: 'assets/images/product10.jpg', bgColor: Color(0xFFE8F4FF), kategori: 'Grooming'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildSearchBar(),
        _buildCategories(),
        _buildCuratedPicksHeader(),
        Expanded(child: _buildProductGrid()),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2),
              color: AppColors.primaryLight,
            ),
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
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const KeranjangScreen()),
            ),
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
            final selected = _selectedCategory == i;
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: selected ? AppColors.primary : AppColors.divider),
                ),
                child: Text(
                  _categories[i],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : AppColors.textMedium,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCuratedPicksHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Curated Picks', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.textDark)),
              Text("Based on your pet's needs", style: TextStyle(fontSize: 12, color: AppColors.textLight, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
  // Filter produk berdasarkan kategori yang dipilih
  final filtered = _selectedCategory == 0
      ? _products
      : _products.where((p) => p.kategori == _categories[_selectedCategory]).toList();

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: filtered.isEmpty
        ? const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 60),
              child: Column(
                children: [
                  Text('🛒', style: TextStyle(fontSize: 48)),
                  SizedBox(height: 12),
                  Text('Belum ada produk di kategori ini',
                      style: TextStyle(fontSize: 14, color: AppColors.textLight)),
                ],
              ),
            ),
          )
        : GridView.builder(
            itemCount: filtered.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.70,
            ),
            itemBuilder: (context, i) => _buildProductCard(filtered[i]),
          ),
  );
}

  Widget _buildProductCard(_ShopProduct product) {
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
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: product.image != null
                  ? Image.asset(
                      product.image!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: product.bgColor,
                      child: Center(
                        child: Text(product.emoji ?? '', style: const TextStyle(fontSize: 56)),
                      ),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
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
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
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
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }
}

class _ShopProduct {
  final String name;
  final double price;
  final String? emoji;
  final String? image;
  final Color bgColor;
  final String kategori;

  const _ShopProduct({
    required this.name,
    required this.price,
    this.emoji,
    this.image,
    required this.bgColor,
    required this.kategori,
  });
}