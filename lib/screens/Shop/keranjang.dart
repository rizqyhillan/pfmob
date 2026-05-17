import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/servis_auth.dart';
import '../../theme/tema_app.dart';
import '../login.dart';
import 'checkout.dart';

class KeranjangScreen extends StatefulWidget {
  const KeranjangScreen({super.key});

  @override
  State<KeranjangScreen> createState() => _KeranjangScreenState();
}

class _KeranjangScreenState extends State<KeranjangScreen> {
  ShopCart? _cart;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
  
    if (AuthService().isLoggedIn) {
      _loadCart();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
  
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginScreen(redirectToProfile: false),
          ),
        );
      });
    }
  }
  String _formatHarga(num harga) => harga.round().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

  Future<void> _loadCart() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final cart = await ApiService.getCart();
      if (!mounted) return;
      setState(() {
        _cart = cart;
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

  Future<void> _updateQty(ShopCartItem item, int qty) async {
    if (qty < 1) return;
    try {
      final cart = await ApiService.updateCartItem(itemId: item.id, jumlah: qty);
      if (mounted) setState(() => _cart = cart);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
    }
  }

  Future<void> _removeItem(ShopCartItem item) async {
    try {
      final cart = await ApiService.removeCartItem(item.id);
      if (mounted) setState(() => _cart = cart);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
    }
  }

  Future<void> _checkout() async {
    final cart = _cart;

    if (cart == null || cart.items.isEmpty) return;

    final success = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutScreen(cart: cart),
      ),
    );

    if (success == true) {
      await _loadCart();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = _cart;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? _buildMessage('⚠️', _error!, 'Coba Lagi', _loadCart)
                      : cart == null || cart.items.isEmpty
                          ? _buildMessage('🛒', 'Keranjang masih kosong', 'Muat ulang', _loadCart)
                          : RefreshIndicator(
                              onRefresh: _loadCart,
                              child: ListView.separated(
                                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                                itemCount: cart.items.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 12),
                                itemBuilder: (_, i) => _buildItem(cart.items[i]),
                              ),
                            ),
            ),
            if (cart != null && cart.items.isNotEmpty) _buildSummary(cart),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(color: AppColors.categoryBg1, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.primary),
              ),
            ),
            const SizedBox(width: 16),
            const Text('Keranjang', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
          ],
        ),
      );

  Widget _buildMessage(String icon, String title, String action, VoidCallback onAction) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textMedium, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onAction, child: Text(action)),
          ],
        ),
      );

  Widget _buildItem(ShopCartItem item) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.divider)),
        child: Row(
          children: [
            Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(color: AppColors.categoryBg1, borderRadius: BorderRadius.circular(14)),
              child: item.imageUrl != null ? ClipRRect(borderRadius: BorderRadius.circular(14), child: Image.network(item.imageUrl!, fit: BoxFit.cover)) : const Center(child: Text('🐾', style: TextStyle(fontSize: 30))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.namaBarang, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                  const SizedBox(height: 4),
                  Text('Rp ${_formatHarga(item.hargaSatuan)}', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      InkWell(onTap: item.jumlah > 1 ? () => _updateQty(item, item.jumlah - 1) : null, child: const Icon(Icons.remove_circle_outline, size: 22)),
                      Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text('${item.jumlah}', style: const TextStyle(fontWeight: FontWeight.w800))),
                      InkWell(onTap: item.jumlah < item.stok ? () => _updateQty(item, item.jumlah + 1) : null, child: const Icon(Icons.add_circle_outline, size: 22)),
                      const Spacer(),
                      IconButton(onPressed: () => _removeItem(item), icon: const Icon(Icons.delete_outline, color: Colors.redAccent)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildSummary(ShopCart cart) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, -4))]),
        child: Column(
          children: [
            Row(
              children: [
                const Text('Total', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textMedium)),
                const Spacer(),
                Text('Rp ${_formatHarga(cart.totalHarga)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _checkout,
                child: const Text('Lanjut Checkout'),
              ),
            ),
          ],
        ),
      );
}
