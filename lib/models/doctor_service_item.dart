class DoctorServiceItem {
  final int id;
  final String namaLayanan;
  final String deskripsi;
  final double harga;

  DoctorServiceItem({
    required this.id,
    required this.namaLayanan,
    required this.deskripsi,
    required this.harga,
  });

  factory DoctorServiceItem.fromJson(Map<String, dynamic> json) => DoctorServiceItem(
        id: json['id'] ?? 0,
        namaLayanan: json['nama_layanan'] ?? '-',
        deskripsi: json['deskripsi'] ?? '',
        harga: double.tryParse((json['estimasi_biaya'] ?? json['harga'] ?? 0).toString()) ?? 0,
      );
}
