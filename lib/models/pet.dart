import 'model_utils.dart';

class Pet {
  final int id;
  final String nama;
  final String jenis;
  final String jenisKelamin;
  final String tanggalLahir;
  final String ras;
  final String umur;
  final String berat;
  final String catatan;
  final String foto;

  Pet({
    required this.id,
    required this.nama,
    required this.jenis,
    required this.jenisKelamin,
    required this.tanggalLahir,
    required this.ras,
    required this.umur,
    required this.berat,
    required this.catatan,
    required this.foto,
  });

  static String _resolveStorageUrl(dynamic raw) {
    return resolveStorageUrl(raw);
  }

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'] ?? 0,
      nama: json['nama_hewan'] ?? '-',
      jenis: json['jenis'] ?? '-',
      jenisKelamin: json['jenis_kelamin'] ?? '-',
      tanggalLahir: json['tanggal_lahir'] ?? '',
      ras: json['ras'] ?? '-',
      umur: json['umur'] ?? '-',
      berat: json['berat']?.toString() ?? '',
      catatan: json['catatan'] ?? '',
      foto: _resolveStorageUrl(json['foto']),
    );
  }
}
