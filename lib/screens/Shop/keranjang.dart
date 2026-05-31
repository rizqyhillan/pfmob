import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../theme/tema_app.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/shop_viewmodel.dart';
import '../../viewmodels/report_viewmodel.dart';
import '../login.dart';
import 'checkout.dart';
import '../profile/shop_report.dart';
import '../profile/transaction_detail.dart';

class KeranjangScreen extends StatefulWidget {
  const KeranjangScreen({super.key});

  @override
  State<KeranjangScreen> createState() => _KeranjangScreenState();
}

class _KeranjangScreenState extends State<KeranjangScreen> {
  ShopCart? _cart;
  List<Transaction> _allTransactions = [];
  List<Transaction> _pendingTransactions = [];
  bool _loading = true;
  String? _error;
  String _filterStatus = 'semua'; // semua | lunas | pending | batal

  @override
@override
void initState() {
  super.initState();

  final authViewModel = context.read<AuthViewModel>();

  if (authViewModel.isLoggedIn) {
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

String _formatHarga(num harga) => harga
    .round()
    .toString()
    .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

  Future<void> _loadCart() async {
    final shopViewModel = context.read<ShopViewModel>();
    final reportViewModel = context.read<ReportViewModel>();
  
    setState(() {
      _loading = true;
      _error = null;
    });
  
    try {
      final cart = await shopViewModel.loadCart();
  
      List<Transaction> all = [];
      List<Transaction> pending = [];
  
      try {
        all = await reportViewModel.loadTransactions();
        pending = all
            .where(
              (t) =>
                  t.status.toLowerCase() == 'pending' &&
                  (t.metodeBayar.toLowerCase() == 'transfer' ||
                      t.metodeBayar.toLowerCase() == 'ewallet'),
            )
            .toList();
      } catch (e) {
        debugPrint('Gagal memuat transaksi: $e');
      }
  
      if (!mounted) return;
  
      setState(() {
        _cart = cart;
        _allTransactions = all;
        _pendingTransactions = pending;
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
      final cart = await context.read<ShopViewModel>().updateCartItem(itemId: item.id, quantity: qty);
      if (mounted) setState(() => _cart = cart);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
    }
  }

  Future<void> _removeItem(ShopCartItem item) async {
    try {
      final cart = await context.read<ShopViewModel>().removeCartItem(item.id);
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

  List<Transaction> _applyFilter(List<Transaction> all) {
    if (_filterStatus == 'semua') return all;
    return all.where((t) => t.status.toLowerCase() == _filterStatus.toLowerCase()).toList();
  }

  String _capitalize(String value) {
    final cleaned = value.trim();

    if (cleaned.isEmpty || cleaned == '-') {
      return '-';
    }

    return cleaned[0].toUpperCase() + cleaned.substring(1);
  }

  bool _isPending(Transaction trx) {
    return trx.status.toLowerCase() == 'pending';
  }

  String _paymentLabel(Transaction trx) {
    final metode = _capitalize(trx.metodeBayar);

    if (_isPending(trx)) {
      return '$metode • Belum dibayar';
    }

    return metode;
  }

  String _totalLabel(Transaction trx) {
    if (_isPending(trx)) {
      return 'Total Tagihan';
    }

    return 'Total Pembayaran';
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              const TabBar(
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textLight,
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                labelStyle: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                tabs: [
                  Tab(text: 'Item Keranjang'),
                  Tab(text: 'Daftar Transaksi'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildCartTab(),
                    _buildTransactionsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
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
            const Spacer(),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ShopReportPage(),
                  ),
                ).then((_) => _loadCart());
              },
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(color: AppColors.categoryBg1, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.receipt_long_outlined, size: 18, color: AppColors.primary),
              ),
            ),
          ],
        ),
      );

  Widget _buildCartTab() {
    final cart = _cart;
    return Column(
      children: [
        if (!_loading && _pendingTransactions.isNotEmpty) _buildPendingBanner(),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : _error != null
                  ? _buildMessage(Image.asset('assets/images/warning.png', width: 42, height: 42,), _error!, 'Coba Lagi', _loadCart)
                  : cart == null || cart.items.isEmpty
                      ? _buildMessage(Image.asset('assets/images/shopping-cart.png', width: 42, height: 42,), 'Keranjang masih kosong', 'Muat ulang', _loadCart)
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
    );
  }

  Widget _buildPendingBanner() {
    final trx = _pendingTransactions.first;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE082)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFF9A825),
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pembayaran Tertunda (${trx.kodeTransaksi})',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total Tagihan: Rp ${_formatHarga(trx.total)}. Silakan selesaikan pembayaran Anda.',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMedium,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TransactionDetailPage(
                          transactionId: trx.id,
                          kodeTransaksi: trx.kodeTransaksi,
                        ),
                      ),
                    ).then((_) => _loadCart());
                  },
                  icon: const Icon(Icons.payment, size: 16),
                  label: const Text('Bayar Sekarang'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsTab() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    
    final filtered = _applyFilter(_allTransactions);
    
    return Column(
      children: [
        _buildFilterChips(),
        Expanded(
          child: filtered.isEmpty
              ? _buildEmptyTransactions()
              : RefreshIndicator(
                  onRefresh: _loadCart,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (ctx, i) => _buildCard(filtered[i]),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      ('semua', 'Semua'),
      ('lunas', 'Lunas'),
      ('pending', 'Pending'),
      ('batal', 'Batal'),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((f) {
            final isActive = _filterStatus == f.$1;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _filterStatus = f.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isActive ? AppColors.primary : AppColors.divider,
                    ),
                  ),
                  child: Text(
                    f.$2,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.white : AppColors.textLight,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCard(Transaction trx) {
    final bulan = ['','Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
    final tanggalStr = trx.tanggal != null
        ? '${trx.tanggal!.day} ${bulan[trx.tanggal!.month]} ${trx.tanggal!.year}, '
          '${trx.tanggal!.hour.toString().padLeft(2, '0')}:${trx.tanggal!.minute.toString().padLeft(2, '0')}'
        : '-';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TransactionDetailPage(
            transactionId: trx.id,
            kodeTransaksi: trx.kodeTransaksi,
          ),
        ),
      ).then((_) => _loadCart()),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(                    
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.categoryBg1,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.receipt_long_outlined,
                            color: AppColors.primary, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(              
                        child: Text(
                          trx.kodeTransaksi,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _buildStatusBadge(trx.status),  
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfo(
                    Icons.person_outline, 'Pelanggan', trx.namaPelanggan),
                ),
                Expanded(
                  child: _buildInfo(
                    Icons.storefront_outlined, 'Kasir', trx.namaKasir),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildInfo(
                    Icons.category_outlined, 'Jenis',
                    _capitalize(trx.jenis)
                  ),
                ),
                Expanded(
                  child: _buildInfo(
                    Icons.payment_outlined, 'Pembayaran',
                    _paymentLabel(trx)
                  ), 
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildInfo(Icons.access_time_outlined, 'Tanggal', tanggalStr),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.categoryBg1,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _totalLabel(trx),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMedium,
                    ),
                  ),
                  Text(
                    'Rp ${_formatHarga(trx.total)}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfo(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: AppColors.textLight),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textLight,
                      fontWeight: FontWeight.w500)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color text;
    String label;

    switch (status.toLowerCase()) {
      case 'lunas':
      case 'paid':
      case 'selesai':
        bg = const Color(0xFFE8F5E9);
        text = const Color(0xFF388E3C);
        label = 'Lunas';
        break;
      case 'pending':
      case 'menunggu':
        bg = const Color(0xFFFFF8E1);
        text = const Color(0xFFF9A825);
        label = 'Pending';
        break;
      case 'batal':
      case 'dibatalkan':
      case 'cancelled':
        bg = const Color(0xFFFFEBEE);
        text = const Color(0xFFD32F2F);
        label = 'Batal';
        break;
      default:
        bg = const Color(0xFFE3F2FD);
        text = const Color(0xFF1976D2);
        label = _capitalize(status);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: text,
        ),
      ),
    );
  }

  Widget _buildEmptyTransactions() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text('🛍️', style: TextStyle(fontSize: 56)),
          SizedBox(height: 16),
          Text('Belum ada transaksi',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark)),
          SizedBox(height: 6),
          Text('Riwayat belanja kamu akan\nmuncul di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13, color: AppColors.textLight, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildMessage(Widget icon, String title, String action, VoidCallback onAction) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textMedium,
          ),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: onAction,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              action,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
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
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, -4))]),
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
