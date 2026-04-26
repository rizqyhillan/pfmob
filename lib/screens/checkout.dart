import 'package:flutter/material.dart';
import '../theme/tema_app.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _selectedPayment = 0;
  String _selectedAddress = 'Jl. Mastrip No. 12, Jember';
  bool _showAddAddress = false;

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _teleponController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  String _selectedKota = 'Jember';
  final TextEditingController _kodeposController = TextEditingController();

  final List<String> _savedAddresses = [
    'Jl. Mastrip No. 12, Jember',
    'Jl. PB. Sudirman No. 52, Jember',
  ];

  final List<_OrderItem> _items = [
    _OrderItem(name: 'Organic Puppy Mix', desc: '2.5 kg • Salmon & Sweet Potato', price: 185000, qty: 1, emoji: '🥣'),
    _OrderItem(name: 'Cotton Rope Tug', desc: 'Large • Eco-friendly Cotton', price: 45000, qty: 2, emoji: '🪢'),
  ];

  final List<_PaymentMethod> _payments = [
    _PaymentMethod(name: 'GoPay', desc: 'Fast & Secure Checkout', icon: Icons.account_balance_wallet_outlined, color: Color(0xFF00AED6)),
    _PaymentMethod(name: 'OVO Cash', desc: 'Direct wallet payment', icon: Icons.wallet_outlined, color: Color(0xFF4C3494)),
    _PaymentMethod(name: 'Bank Transfer', desc: 'BCA, Mandiri, BNI', icon: Icons.account_balance_outlined, color: AppColors.textDark),
    _PaymentMethod(name: 'COD', desc: 'Bayar saat barang tiba', icon: Icons.delivery_dining_outlined, color: Color(0xFF4CAF50)),
  ];

  int get _subtotal => _items.fold(0, (sum, i) => sum + i.price * i.qty);
  int get _shipping => 12000;
  int get _tax => (_subtotal * 0.11).round();
  int get _total => _subtotal + _shipping + _tax;

  @override
  void initState() {
  super.initState();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _teleponController.dispose();
    _alamatController.dispose();
    _kodeposController.dispose();
    super.dispose();
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
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAlamatSection(),
                    const SizedBox(height: 24),
                    _buildOrderSummary(),
                    const SizedBox(height: 24),
                    _buildPaymentMethod(),
                    const SizedBox(height: 24),
                    _buildPriceSummary(),
                    const SizedBox(height: 16),
                    _buildSSLBadge(),
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
          const Text('Checkout', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
        ],
      ),
    );
  }

  // ─── ALAMAT ───────────────────────────────────────────────
  Widget _buildAlamatSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Alamat Pengiriman', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
            GestureDetector(
              onTap: () => setState(() => _showAddAddress = !_showAddAddress),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _showAddAddress ? 'Batal' : '+ Tambah',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Daftar alamat tersimpan
        ..._savedAddresses.map((addr) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GestureDetector(
            onTap: () => setState(() => _selectedAddress = addr),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _selectedAddress == addr ? AppColors.primary : AppColors.divider,
                  width: _selectedAddress == addr ? 2 : 1,
                ),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Row(
                children: [
                  Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: _selectedAddress == addr ? AppColors.primary.withOpacity(0.1) : AppColors.categoryBg1,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.location_on_outlined,
                      color: _selectedAddress == addr ? AppColors.primary : AppColors.textLight, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(addr, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                  ),
                  if (_selectedAddress == addr)
                    const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
                ],
              ),
            ),
          ),
        )),

        // Form tambah alamat baru
        if (_showAddAddress) _buildFormTambahAlamat(),
      ],
    );
  }

  Widget _buildFormTambahAlamat() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tambah Alamat Baru', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark)),
          const SizedBox(height: 14),
          _buildInputField(_namaController, 'Nama Penerima', Icons.person_outline),
          const SizedBox(height: 10),
          _buildInputField(_teleponController, 'No. Telepon', Icons.phone_outlined, keyboardType: TextInputType.phone),
          const SizedBox(height: 10),
          _buildInputField(_alamatController, 'Alamat Lengkap', Icons.home_outlined, maxLines: 2),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
  child: Container(
    decoration: BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.divider),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 12),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: _selectedKota,
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textLight),
        style: const TextStyle(fontSize: 13, color: AppColors.textDark),
        items: const [
          DropdownMenuItem(value: 'Jember', child: Text('Jember')),
          // nanti bisa tambah kota lain di sini
        ],
        onChanged: (value) {
          setState(() => _selectedKota = value!);
        },
      ),
    ),
  ),
),
              const SizedBox(width: 10),
              Expanded(child: _buildInputField(_kodeposController, 'Kode Pos', Icons.markunread_mailbox_outlined, keyboardType: TextInputType.number)),
            ],
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () {
              if (_alamatController.text.isNotEmpty) {
                final newAddr = '${_alamatController.text}, $_selectedKota';
                setState(() {
                  _savedAddresses.add(newAddr);
                  _selectedAddress = newAddr;
                  _showAddAddress = false;
                  _namaController.clear();
                  _teleponController.clear();
                  _alamatController.clear();
                  _kodeposController.clear();
                });
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
              child: const Text('Simpan Alamat', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String hint, IconData icon, {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 13, color: AppColors.textDark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 13),
          prefixIcon: Icon(icon, color: AppColors.textLight, size: 18),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  // ─── ORDER SUMMARY ────────────────────────────────────────
  Widget _buildOrderSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Order Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
            Text('${_items.length} ITEMS', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textLight, letterSpacing: 1)),
          ],
        ),
        const SizedBox(height: 14),
        ..._items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildOrderCard(item),
        )),
      ],
    );
  }

  Widget _buildOrderCard(_OrderItem item) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(color: AppColors.categoryBg1, borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text(item.emoji, style: const TextStyle(fontSize: 32))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                const SizedBox(height: 2),
                Text(item.desc, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Rp ${_formatHarga(item.price)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.categoryBg1, borderRadius: BorderRadius.circular(8)),
                      child: Text('Qty: ${item.qty}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMedium)),
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

  // ─── PAYMENT ──────────────────────────────────────────────
  Widget _buildPaymentMethod() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Payment Method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(color: AppColors.categoryBg1, borderRadius: BorderRadius.circular(18)),
          child: Column(
            children: List.generate(_payments.length, (i) {
              final payment = _payments[i];
              final selected = _selectedPayment == i;
              return GestureDetector(
                onTap: () => setState(() => _selectedPayment = i),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    border: i < _payments.length - 1 ? Border(bottom: BorderSide(color: AppColors.divider)) : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                        child: Icon(payment.icon, color: payment.color, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(payment.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                            Text(payment.desc, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
                          ],
                        ),
                      ),
                      Container(
                        width: 22, height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: selected ? AppColors.primary : AppColors.divider, width: 2),
                          color: selected ? AppColors.primary : Colors.white,
                        ),
                        child: selected ? const Icon(Icons.circle, color: Colors.white, size: 10) : null,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  // ─── PRICE SUMMARY ────────────────────────────────────────
  Widget _buildPriceSummary() {
    return Column(
      children: [
        _buildPriceRow('Subtotal', _subtotal),
        const SizedBox(height: 10),
        _buildPriceRow('Shipping (Standard)', _shipping),
        const SizedBox(height: 10),
        _buildPriceRow('Tax (11%)', _tax),
        const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Divider()),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Total Amount', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark)),
            Text('Rp ${_formatHarga(_total)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary)),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, int amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textLight, fontWeight: FontWeight.w500)),
        Text('Rp ${_formatHarga(amount)}', style: const TextStyle(fontSize: 14, color: AppColors.textMedium, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildSSLBadge() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(color: const Color(0xFFE8F5F3), borderRadius: BorderRadius.circular(14)),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.verified_user_outlined, color: Color(0xFF4A9B8E), size: 18),
          SizedBox(width: 8),
          Text('SSL Encrypted Secure Payment', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF4A9B8E))),
        ],
      ),
    );
  }

  Widget _buildCheckoutButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, -4))],
      ),
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pembayaran berhasil! 🎉'),
              backgroundColor: Color(0xFF4A9B8E),
              duration: Duration(seconds: 2),
              ),
            );
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                Navigator.popUntil(context, (route) => route.isFirst);
                }
              });
            },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(16)),
          child: const Text('Bayar Sekarang', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
        ),
      ),
    );
  }

  String _formatHarga(int harga) {
    return harga.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }
}

class _OrderItem {
  final String name;
  final String desc;
  final int price;
  final int qty;
  final String emoji;
  const _OrderItem({required this.name, required this.desc, required this.price, required this.qty, required this.emoji});
}

class _PaymentMethod {
  final String name;
  final String desc;
  final IconData icon;
  final Color color;
  const _PaymentMethod({required this.name, required this.desc, required this.icon, required this.color});
}