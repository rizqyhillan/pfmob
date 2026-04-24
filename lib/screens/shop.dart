import 'package:flutter/material.dart';
import '../theme/tema_app.dart';

class ShopContent extends StatefulWidget {
  const ShopContent({super.key});

  @override
  State<ShopContent> createState() => _ShopContentState();
}

class _ShopContentState extends State<ShopContent> {
  int _selectedCategory = 0;
  final List<String> _categories = ['All Products', 'Food', 'Toys', 'Grooming', 'Vitamins'];

  final List<_ShopProduct> _products = [
    _ShopProduct(name: 'Organic Grain-Free Salmon', price: 24.99, rating: 4.9, reviews: 124, emoji: '🐟', bgColor: Color(0xFFE8F4FF)),
    _ShopProduct(name: 'Dura-Tough Rubber Bone', price: 12.50, rating: 4.7, reviews: 89, emoji: '🦴', bgColor: Color(0xFFFFF3E8)),
    _ShopProduct(name: 'Eco-Friendly Shampoo', price: 18.00, rating: 5.0, reviews: 56, emoji: '🧴', bgColor: Color(0xFFE8F5F3)),
    _ShopProduct(name: 'Hip & Joint Daily', price: 22.00, rating: 4.8, reviews: 210, emoji: '💊', bgColor: Color(0xFFF3F0FF)),
    _ShopProduct(name: 'Grooming Brush Set', price: 32.00, rating: 4.6, reviews: 78, emoji: '🪮', bgColor: Color(0xFFFFF3E8)),
    _ShopProduct(name: 'Pet Vitamin Drops', price: 15.99, rating: 4.5, reviews: 143, emoji: '🌿', bgColor: Color(0xFFE8F4FF)),
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
            child: const Icon(Icons.shopping_cart_outlined, color: AppColors.textDark, size: 22),
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
                child: Text(_categories[i], style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? Colors.white : AppColors.textMedium)),
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
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
            child: const Text('View All', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        itemCount: _products.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: 0.72,
        ),
        itemBuilder: (context, i) => _buildProductCard(_products[i]),
      ),
    );
  }

  Widget _buildProductCard(_ShopProduct product) {
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
                  decoration: BoxDecoration(color: product.bgColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(18))),
                  child: Center(child: Text(product.emoji, style: const TextStyle(fontSize: 56))),
                ),
                Positioned(
                  top: 8, right: 10,
                  child: Container(
                    width: 30, height: 30,
                    decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6)]),
                    child: const Icon(Icons.favorite_border, color: AppColors.textLight, size: 16),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: AppColors.gold, size: 14),
                    const SizedBox(width: 3),
                    Text('${product.rating} (${product.reviews})', style: const TextStyle(fontSize: 11, color: AppColors.textLight, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(product.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark, height: 1.3), maxLines: 2),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('\$${product.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                      child: const Text('Beli', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
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
}

class _ShopProduct {
  final String name;
  final double price;
  final double rating;
  final int reviews;
  final String emoji;
  final Color bgColor;
  const _ShopProduct({required this.name, required this.price, required this.rating, required this.reviews, required this.emoji, required this.bgColor});
}