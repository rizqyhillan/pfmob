import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/tema_app.dart';
import '../../viewmodels/report_viewmodel.dart';
import 'transaction_detail.dart';

import '../../models/transaction.dart';
// ─── Halaman utama ───────────────────────────────────────────
class ShopReportPage extends StatefulWidget {
  const ShopReportPage({super.key});

  @override
  State<ShopReportPage> createState() => _ShopReportPageState();
}

class _ShopReportPageState extends State<ShopReportPage> {
  late Future<List<Transaction>> _future;
  String _filterStatus = 'semua'; // semua | lunas | pending | batal

  @override
  void initState() {
    super.initState();
    _future = context.read<ReportViewModel>().loadTransactions();
  }

  List<Transaction> _applyFilter(List<Transaction> all) {
    if (_filterStatus == 'semua') return all;
    return all.where((t) => t.status == _filterStatus).toList();
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
        title: const Text(
          'Riwayat Belanja',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textDark),
            onPressed: () => setState(() => _future = context.read<ReportViewModel>().loadTransactions()),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: FutureBuilder<List<Transaction>>(
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
                          const Text('Gagal memuat data',
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
                            onPressed: () => setState(
                                () => _future = context.read<ReportViewModel>().loadTransactions()),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final all = snapshot.data ?? [];
                final filtered = _applyFilter(all);

                if (filtered.isEmpty) return _buildEmpty();

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (ctx, i) => _buildCard(filtered[i]),
                );
              },
            ),
          ),
        ],
      ),
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
      color: const Color(0xFFF8F4EF),
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
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TransactionDetailPage(
              transactionId: trx.id,
              kodeTransaksi: trx.kodeTransaksi,
            ),
          ),
        );
        // Refresh list when returning from detail (status may have changed)
        if (mounted) {
          setState(() => _future = context.read<ReportViewModel>().loadTransactions());
        }
      },
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
          // Baris atas: kode + status badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
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
                  Text(
                    trx.kodeTransaksi,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              _buildStatusBadge(trx.status),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Info grid
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

          // Total
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
                  'Rp ${_formatRupiah(trx.total)}',
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
    ), // tutup Container
    ); // tutup GestureDetector
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

  Widget _buildEmpty() {
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

  String _formatRupiah(double amount) {
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
}