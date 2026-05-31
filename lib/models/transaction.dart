class Transaction {
  final int id;
  final String kodeTransaksi;
  final String namaPelanggan;
  final String namaKasir;
  final String jenis;
  final double total;
  final String metodeBayar;
  final String status;
  final DateTime? tanggal;

  const Transaction({
    required this.id,
    required this.kodeTransaksi,
    required this.namaPelanggan,
    required this.namaKasir,
    required this.jenis,
    required this.total,
    required this.metodeBayar,
    required this.status,
    this.tanggal,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? 0,
      kodeTransaksi: json['kode_transaksi'] ?? '-',
      namaPelanggan: json['nama_pelanggan'] ?? json['pelanggan']?['nama'] ?? '-',
      namaKasir: json['nama_kasir'] ?? json['kasir']?['nama'] ?? '-',
      jenis: json['jenis'] ?? '-',
      total: double.tryParse(json['total'].toString()) ?? 0,
      metodeBayar: json['metode_bayar'] ?? '-',
      status: json['status'] ?? '-',
      tanggal: json['tanggal'] != null
          ? DateTime.tryParse(json['tanggal'])
          : null,
    );
  }
}
