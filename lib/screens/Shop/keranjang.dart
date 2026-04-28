import 'package:flutter/material.dart';
import '../../theme/tema_app.dart';
import 'checkout.dart';
import 'shop.dart';

class KeranjangScreen extends StatefulWidget {
  const KeranjangScreen({super.key});

  @override
  State<KeranjangScreen> createState() => _KeranjangScreenState();
}

class _KeranjangScreenState extends State<KeranjangScreen> {
  final List<_CartItem> _items = [
    _CartItem(name: 'Steam Grooming Brush', category: 'Grooming', price: 185000, qty: 2, image: 'assets/images/product5.jpg', selected: true),
    _CartItem(name: 'Paw Balm', category: 'Skincare', price: 55000, qty: 1, image: 'assets/images/product8.jpg', selected: true),
    _CartItem(name: 'Ear Finger Wipes', category: 'Grooming', price: 45000, qty: 1, image: 'assets/images/product7.jpg', selected: false),
  ];

  bool get _allSelected => _items.every((i) => i.selected);
  int get _totalHarga => _items.where((i) => i.selected).fold(0, (sum, i) => sum + i.price * i.qty);
  int get _totalItem => _items.where((i) => i.selected).length;

  void _toggleAll(bool? val) {
    setState(() {
      for (var item in _items) item.selected = val ?? false;
    });
  }

  void _hapusSemua() {
    setState(() => _items.removeWhere((i) => i.selected));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  children: [
                    _buildPilihSemua(),
                    const SizedBox(height: 12),
                    ..._items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildCartCard(item),
                    )),
                  ],
                ),
              ),
            ),
            _buildCheckoutBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(color: AppColors.categoryBg1, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 16),
          const Text('Keranjang', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
        ],
      ),
    );
  }

  Widget _buildPilihSemua() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.divider)),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _toggleAll(!_allSelected),
            child: Container(
              width: 24, height: 24,
              decoration: BoxDecoration(
                color: _allSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: _allSelected ? AppColors.primary : AppColors.divider, width: 2),
              ),
              child: _allSelected ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
            ),
          ),
          const SizedBox(width: 12),
          const Text('Pilih Semua', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const Spacer(),
          GestureDetector(
            onTap: _hapusSemua,
            child: Row(
              children: const [
                Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.primary),
                SizedBox(width: 4),
                Text('Hapus Semua', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartCard(_CartItem item) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => setState(() => item.selected = !item.selected),
            child: Container(
              width: 24, height: 24,
              decoration: BoxDecoration(
                color: item.selected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: item.selected ? AppColors.primary : AppColors.divider, width: 2),
              ),
              child: item.selected ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
            ),
          ),
          const SizedBox(width: 12),
          // Gambar produk
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              item.image,
              width: 70, height: 70,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                const SizedBox(height: 2),
                Text(item.category, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
                const SizedBox(height: 6),
                Text('Rp ${_formatHarga(item.price)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () => setState(() { if (item.qty > 1) item.qty--; }),
                      child: Container(
                        width: 30, height: 30,
                        decoration: BoxDecoration(color: AppColors.categoryBg1, borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.remove, size: 16, color: AppColors.textDark),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('${item.qty}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => item.qty++),
                      child: Container(
                        width: 30, height: 30,
                        decoration: BoxDecoration(
                          color: item.selected ? AppColors.primary : AppColors.divider,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.add, size: 16, color: Colors.white),
                      ),
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

  Widget _buildCheckoutBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, -4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('TOTAL PEMBAYARAN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textLight, letterSpacing: 1)),
              Text('($_totalItem Item terpilih)', style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
            ],
          ),
          const SizedBox(height: 4),
          Text('Rp ${_formatHarga(_totalHarga)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark)),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CheckoutScreen()),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(16)),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Checkout Sekarang', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatHarga(int harga) {
    return harga.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }
}

class _CartItem {
  final String name;
  final String category;
  final int price;
  int qty;
  final String image;
  bool selected;
  _CartItem({required this.name, required this.category, required this.price, required this.qty, required this.image, required this.selected});
}