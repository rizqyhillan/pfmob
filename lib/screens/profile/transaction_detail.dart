import 'package:flutter/material.dart';
import '../../theme/tema_app.dart';
import '../../services/api_service.dart';

// ─── Model Item Barang dalam struk ───────────────────────────
class TransactionItem {
  final String namaItem;
  final int jumlah;
  final double hargaSatuan;
  final double subtotal;
  final String tipe; // 'barang' atau 'layanan'

  const TransactionItem({
    required this.namaItem,
    required this.jumlah,
    required this.hargaSatuan,
    required this.subtotal,
    required this.tipe,
  });

  factory TransactionItem.fromBarang(Map<String, dynamic> json) {
    return TransactionItem(
      namaItem: json['barang']?['nama_barang'] ?? '-',
      jumlah: json['jumlah'] ?? 1,
      hargaSatuan: double.tryParse(json['harga_satuan'].toString()) ?? 0,
      subtotal: double.tryParse(json['subtotal'].toString()) ?? 0,
      tipe: 'barang',
    );
  }

  factory TransactionItem.fromLayanan(Map<String, dynamic> json) {
    return TransactionItem(
      namaItem: json['layanan']?['nama_layanan'] ?? '-',
      jumlah: json['jumlah'] ?? 1,
      hargaSatuan: double.tryParse(json['harga_satuan'].toString()) ?? 0,
      subtotal: double.tryParse(json['subtotal'].toString()) ?? 0,
      tipe: 'layanan',
    );
  }
}

// ─── Model Detail Transaksi (struk lengkap) ──────────────────
class TransactionDetail {
  final int id;
  final String kodeTransaksi;
  final String namaPelanggan;
  final String namaKasir;
  final String jenis;
  final String metodeBayar;
  final String status;
  final DateTime? tanggal;
  final double subtotal;
  final double diskon;
  final double total;
  final double jumlahBayar;
  final double kembalian;
  final String? catatan;
  final List<TransactionItem> items;

  const TransactionDetail({
    required this.id,
    required this.kodeTransaksi,
    required this.namaPelanggan,
    required this.namaKasir,
    required this.jenis,
    required this.metodeBayar,
    required this.status,
    this.tanggal,
    required this.subtotal,
    required this.diskon,
    required this.total,
    required this.jumlahBayar,
    required this.kembalian,
    this.catatan,
    required this.items,
  });

  factory TransactionDetail.fromJson(Map<String, dynamic> json) {
    final List<TransactionItem> items = [];

    // Barang
    if (json['barang'] != null) {
      for (final b in json['barang']) {
        items.add(TransactionItem.fromBarang(b));
      }
    }
    // Layanan
    if (json['layanan'] != null) {
      for (final l in json['layanan']) {
        items.add(TransactionItem.fromLayanan(l));
      }
    }

    final jumlahBayar =
        double.tryParse(json['jumlah_bayar'].toString()) ?? 0;
    final total = double.tryParse(json['total'].toString()) ?? 0;

    return TransactionDetail(
      id: json['id'] ?? 0,
      kodeTransaksi: json['kode_transaksi'] ?? '-',
      namaPelanggan: json['pelanggan']?['nama'] ?? '-',
      namaKasir: json['kasir']?['nama'] ?? '-',
      jenis: json['jenis'] ?? '-',
      metodeBayar: json['metode_bayar'] ?? '-',
      status: json['status'] ?? '-',
      tanggal: json['tanggal'] != null
          ? DateTime.tryParse(json['tanggal'])
          : null,
      subtotal: double.tryParse(json['subtotal'].toString()) ?? 0,
      diskon: double.tryParse(json['diskon'].toString()) ?? 0,
      total: total,
      jumlahBayar: jumlahBayar,
      kembalian: double.tryParse(json['kembalian'].toString()) ?? 0, // dari DB
      catatan: json['catatan'],
      items: items,
    );
  }
}

// ─── Halaman Struk ───────────────────────────────────────────
class TransactionDetailPage extends StatefulWidget {
  final int transactionId;
  final String kodeTransaksi; // untuk ditampilkan saat loading

  const TransactionDetailPage({
    super.key,
    required this.transactionId,
    required this.kodeTransaksi,
  });

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  late Future<TransactionDetail> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService.getTransactionDetail(widget.transactionId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F4EF),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                size: 16, color: AppColors.textDark),
          ),
        ),
        title: Text(
          widget.kodeTransaksi,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<TransactionDetail>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('😵', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 16),
                    const Text('Gagal memuat struk',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark)),
                    const SizedBox(height: 6),
                    Text(snapshot.error.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textLight)),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => setState(() {
                        _future =
                            ApiService.getTransactionDetail(widget.transactionId);
                      }),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          return _buildStruk(snapshot.data!);
        },
      ),
    );
  }

  Widget _buildStruk(TransactionDetail trx) {
    final bulan = ['','Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
    final tanggalStr = trx.tanggal != null
        ? '${trx.tanggal!.day} ${bulan[trx.tanggal!.month]} ${trx.tanggal!.year}  '
          '${trx.tanggal!.hour.toString().padLeft(2, '0')}:${trx.tanggal!.minute.toString().padLeft(2, '0')}'
        : '-';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // ── Struk Card ──────────────────────────────────────
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.divider),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header struk
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryDark, AppColors.primary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      const Text('🐾',
                          style: TextStyle(fontSize: 32)),
                      const SizedBox(height: 6),
                      const Text(
                        'PawPet Clinic',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Struk Pembayaran',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Kode & Tanggal
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfo2('Kode', trx.kodeTransaksi),
                          _buildInfo2('Tanggal', tanggalStr,
                              align: TextAlign.right),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfo2('Pelanggan', trx.namaPelanggan),
                          _buildInfo2('Kasir', trx.namaKasir,
                              align: TextAlign.right),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfo2('Metode Bayar',
                              _capitalize(trx.metodeBayar)),
                          _buildStatusBadge(trx.status),
                        ],
                      ),

                      const SizedBox(height: 16),
                      _buildDashedDivider(),
                      const SizedBox(height: 16),

                      // Header tabel item
                      Row(
                        children: const [
                          Expanded(
                              flex: 4,
                              child: Text('Item',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textLight))),
                          SizedBox(
                              width: 30,
                              child: Text('Qty',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textLight))),
                          Expanded(
                              flex: 3,
                              child: Text('Subtotal',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textLight))),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // List item
                      ...trx.items.map((item) => Padding(
                            padding:
                                const EdgeInsets.symmetric(vertical: 5),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.namaItem,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                      Text(
                                        'Rp ${_formatRp(item.hargaSatuan)}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 30,
                                  child: Text(
                                    '${item.jumlah}x',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textMedium,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    'Rp ${_formatRp(item.subtotal)}',
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),

                      const SizedBox(height: 16),
                      _buildDashedDivider(),
                      const SizedBox(height: 16),

                      // Subtotal, diskon, total
                      _buildSummaryRow('Subtotal', trx.subtotal),
                      if (trx.diskon > 0) ...[
                        const SizedBox(height: 6),
                        _buildSummaryRow('Diskon', trx.diskon,
                            isDiskon: true),
                      ],
                      const SizedBox(height: 10),

                      // Total box
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.categoryBg1,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.primary.withOpacity(0.2)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('TOTAL',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary)),
                            Text('Rp ${_formatRp(trx.total)}',
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary)),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),
                      _buildSummaryRow(
                          'Bayar (${_capitalize(trx.metodeBayar)})',
                          trx.jumlahBayar),
                      const SizedBox(height: 6),

                      // Kembalian box
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Kembalian',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF388E3C))),
                            Text('Rp ${_formatRp(trx.kembalian)}',
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF388E3C))),
                          ],
                        ),
                      ),

                      // Catatan
                      if (trx.catatan != null &&
                          trx.catatan!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildDashedDivider(),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.notes_outlined,
                                size: 16, color: AppColors.textLight),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                trx.catatan!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textLight,
                                  fontStyle: FontStyle.italic,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 16),
                      _buildDashedDivider(),
                      const SizedBox(height: 14),

                      const Text(
                        'Terima kasih telah berkunjung ke PawPet Clinic! 🐾',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textLight,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildInfo2(String label, String value,
      {TextAlign align = TextAlign.left}) {
    return Column(
      crossAxisAlignment: align == TextAlign.right
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 11,
                color: AppColors.textLight,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 2),
        Text(value,
            textAlign: align,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark)),
      ],
    );
  }

  Widget _buildSummaryRow(String label, double amount,
      {bool isDiskon = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                color: AppColors.textLight,
                fontWeight: FontWeight.w500)),
        Text(
          '${isDiskon ? '- ' : ''}Rp ${_formatRp(amount)}',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDiskon
                ? const Color(0xFFD32F2F)
                : AppColors.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color text;
    String label;
    switch (status) {
      case 'lunas':
        bg = const Color(0xFFE8F5E9);
        text = const Color(0xFF388E3C);
        label = 'Lunas';
        break;
      case 'pending':
        bg = const Color(0xFFFFF8E1);
        text = const Color(0xFFF9A825);
        label = 'Pending';
        break;
      default:
        bg = const Color(0xFFFFEBEE);
        text = const Color(0xFFD32F2F);
        label = 'Batal';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: text)),
    );
  }

  Widget _buildDashedDivider() {
    return LayoutBuilder(builder: (context, constraints) {
      const dashWidth = 6.0;
      const dashSpace = 4.0;
      final count =
          (constraints.maxWidth / (dashWidth + dashSpace)).floor();
      return Row(
        children: List.generate(
          count,
          (_) => Container(
            width: dashWidth,
            height: 1,
            margin: const EdgeInsets.only(right: dashSpace),
            color: AppColors.divider,
          ),
        ),
      );
    });
  }

  String _formatRp(double amount) {
    final str = amount.toInt().toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
      count++;
    }
    return buffer.toString().split('').reversed.join('');
  }

  String _capitalize(String s) {
  final value = s.trim();

  if (value.isEmpty || value == '-') {
    return '-';
  }

  return value[0].toUpperCase() + value.substring(1);
}
}