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

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  static String _string(dynamic value, {String fallback = '-'}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  static int _int(dynamic value, {int fallback = 1}) {
    return int.tryParse((value ?? fallback).toString()) ?? fallback;
  }

  static double _double(dynamic value) {
    return double.tryParse((value ?? 0).toString()) ?? 0;
  }

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    final barang = _asMap(json['barang']);
    final layanan = _asMap(json['layanan']);
    final tipe = _string(
      json['tipe'] ?? (json.containsKey('id_barang') ? 'barang' : 'layanan'),
      fallback: 'barang',
    );

    return TransactionItem(
      namaItem: _string(
        json['nama'] ??
            json['nama_barang'] ??
            json['nama_layanan'] ??
            barang['nama_barang'] ??
            layanan['nama_layanan'],
      ),
      jumlah: _int(json['jumlah']),
      hargaSatuan: _double(json['harga_satuan']),
      subtotal: _double(json['subtotal']),
      tipe: tipe,
    );
  }

  factory TransactionItem.fromBarang(Map<String, dynamic> json) {
    return TransactionItem.fromJson({
      ...json,
      'tipe': json['tipe'] ?? 'barang',
    });
  }

  factory TransactionItem.fromLayanan(Map<String, dynamic> json) {
    return TransactionItem.fromJson({
      ...json,
      'tipe': json['tipe'] ?? 'layanan',
    });
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

    if (json['items'] is List) {
      for (final item in json['items']) {
        items.add(TransactionItem.fromJson(Map<String, dynamic>.from(item)));
      }
    } else {
      if (json['barang'] is List) {
        for (final b in json['barang']) {
          items.add(TransactionItem.fromBarang(Map<String, dynamic>.from(b)));
        }
      }
      if (json['layanan'] is List) {
        for (final l in json['layanan']) {
          items.add(TransactionItem.fromLayanan(Map<String, dynamic>.from(l)));
        }
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
