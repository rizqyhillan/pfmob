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
  final String? snapToken;
  final String? redirectUrl;
  final String? paymentStatus;
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
    this.snapToken,
    this.redirectUrl,
    this.paymentStatus,
    required this.items,
  });

  factory TransactionDetail.fromJson(Map<String, dynamic> rawJson) {
    final json = rawJson.containsKey('data') ? rawJson['data'] as Map<String, dynamic> : rawJson;
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
      namaPelanggan: json['nama_pelanggan'] ?? json['pelanggan']?['nama'] ?? '-',
      namaKasir: json['nama_kasir'] ?? json['kasir']?['nama'] ?? '-',
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
      snapToken: json['snap_token']?.toString(),
      redirectUrl: json['redirect_url']?.toString(),
      paymentStatus: json['payment_status']?.toString(),
      items: items,
    );
  }
}

// ─── Halaman Struk ───────────────────────────────────────────
