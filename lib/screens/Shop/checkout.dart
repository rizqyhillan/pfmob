import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/tema_app.dart';
import 'snap_webview.dart';

class CheckoutScreen extends StatefulWidget {
  final ShopCart cart;

  const CheckoutScreen({
    super.key,
    required this.cart,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _catatanController = TextEditingController();
  bool _loading = false;

  String _metodeBayar = '';

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  String _formatHarga(num harga) {
    return harga.round().toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
  }

  Future<void> _buatPesanan() async {
    if (_metodeBayar.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pilih metode pembayaran terlebih dahulu'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
    return;
  }

    if (_loading) return;

    setState(() => _loading = true);

    try {
      final trx = await ApiService.checkoutCart(
        metodeBayar: _metodeBayar,
        catatan: _catatanController.text.trim().isEmpty
            ? null
            : _catatanController.text.trim(),
      );

      if (!mounted) return;

      final redirectUrl = trx['redirect_url']?.toString();
      final kodeTransaksi = trx['kode_transaksi']?.toString() ?? '-';

      if (redirectUrl != null && (_metodeBayar == 'transfer')) {
        // Pindah ke WebView Midtrans
        await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => SnapWebViewScreen(
              url: redirectUrl,
              orderId: kodeTransaksi,
            ),
          ),
        );

        if (!mounted) return;

        // Tampilkan dialog penyelesaian
        await showModalBottomSheet<void>(
          context: context,
          isDismissible: false,
          enableDrag: false,
          backgroundColor: Colors.transparent,
          barrierColor: Colors.black.withValues(alpha: 0.5),
          builder: (_) => Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(height: 28),
                Image.asset(
                  'assets/images/check.png',
                  width: 80,
                  height: 80,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Pesanan Dibuat!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pembayaran kamu sedang diproses.\nCek status di Riwayat Belanja ya!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppColors.textLight, height: 1.5),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.categoryBg1,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.receipt_long_outlined, color: AppColors.primary, size: 18),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Kode Pesanan', style: TextStyle(fontSize: 11, color: AppColors.textLight)),
                          Text(kodeTransaksi, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () { Navigator.popUntil(context, (route) => route.isFirst); },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(16)),
                    child: const Text('Kembali ke Beranda', textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
    // COD payment flow
    await showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(height: 28),
                Image.asset('assets/images/check.png', width: 80, height: 80, fit: BoxFit.contain),
                const SizedBox(height: 20),
                const Text(
                  'Pesanan Dibuat!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pesanan COD kamu berhasil dibuat.\nKurir akan mengantarkan pesanan dan\npembayaran dilakukan saat barang tiba.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppColors.textLight, height: 1.5),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.categoryBg1, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Icon(Icons.receipt_long_outlined, color: AppColors.primary, size: 18),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Kode Pesanan', style: TextStyle(fontSize: 11, color: AppColors.textLight)),
                          Text(kodeTransaksi, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () { Navigator.popUntil(context, (route) => route.isFirst); },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(16)),
                    child: const Text('Kembali ke Beranda', textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = widget.cart;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoBox(),
                    const SizedBox(height: 20),
                    _buildOrderSummary(cart),
                    const SizedBox(height: 20),
                    _buildCatatanSection(),
                    const SizedBox(height: 20),
                    _buildPaymentMethod(),
                    const SizedBox(height: 20),
                    _buildPriceSummary(cart),
                  ],
                ),
              ),
            ),
            _buildCheckoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: _loading ? null : () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.categoryBg1,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Checkout',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.accentLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.25)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: AppColors.accent),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Checkout ini hanya membuat pesanan shopping dengan status pending. Payment gateway akan dilanjutkan oleh tim payment.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textMedium,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(ShopCart cart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Ringkasan Pesanan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const Spacer(),
            Text(
              '${cart.totalItem} ITEM',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textLight,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ...cart.items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildOrderCard(item),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(ShopCartItem item) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.categoryBg1,
              borderRadius: BorderRadius.circular(12),
            ),
            child: item.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      item.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Text('🐾', style: TextStyle(fontSize: 26)),
                      ),
                    ),
                  )
                : const Center(
                    child: Text('🐾', style: TextStyle(fontSize: 26)),
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.namaBarang,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.kategori,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      'Rp ${_formatHarga(item.hargaSatuan)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.categoryBg1,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Qty: ${item.jumlah}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMedium,
                        ),
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

  Widget _buildCatatanSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Catatan Pesanan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: TextField(
            controller: _catatanController,
            maxLines: 3,
            enabled: !_loading,
            decoration: const InputDecoration(
              hintText: 'Contoh: Tolong hubungi sebelum pengiriman',
              hintStyle: TextStyle(
                color: AppColors.textLight,
                fontSize: 13,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethod() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Metode Pembayaran',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),

        const SizedBox(height: 10),
        _paymentTile(
          value: 'transfer',
          title: 'Transfer Bank',
          subtitle: 'Status tetap pending sampai payment diproses',
          icon: Icons.account_balance_outlined,
        ),
        const SizedBox(height: 10),
        _paymentTile(
          value: 'cash',
          title: 'COD',
          subtitle: 'Bayar saat barang tiba diantar kurir',
          icon: Icons.payments_outlined,
        ),
      ],
    );
  }

  Widget _paymentTile({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final selected = _metodeBayar == value;

    return GestureDetector(
      onTap: _loading ? null : () => setState(() => _metodeBayar = value),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.categoryBg1,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: selected ? AppColors.primary : AppColors.textLight,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textLight,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected ? AppColors.primary : AppColors.textLight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSummary(ShopCart cart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          _buildPriceRow('Subtotal Produk', cart.totalHarga),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Pesanan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                'Rp ${_formatHarga(cart.totalHarga)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, num amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textLight,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          'Rp ${_formatHarga(amount)}',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textMedium,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildCheckoutButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _loading ? null : _buatPesanan,
          child: Text(_loading ? 'Memproses...' : 'Buat Pesanan'),
        ),
      ),
    );
  }
}