import 'model_utils.dart';

class MedicalRecord {
  final int id;
  final String namaHewan;
  final String jenisHewan;
  final String rasHewan;
  final String umurHewan;
  final double? beratHewan;
  final String namaPemilik;
  final String namaDokter;
  final String spesialisasiDokter;
  final double? beratSaatItu;
  final DateTime tanggal;
  final String diagnosa;
  final String tindakan;
  final String resep;
  final String? catatan;
  final String? fotoUrl;

  const MedicalRecord({
    required this.id,
    required this.namaHewan,
    required this.jenisHewan,
    required this.rasHewan,
    required this.umurHewan,
    this.beratHewan,
    required this.namaPemilik,
    required this.namaDokter,
    required this.spesialisasiDokter,
    this.beratSaatItu,
    required this.tanggal,
    required this.diagnosa,
    required this.tindakan,
    required this.resep,
    this.catatan,
    this.fotoUrl,
  });

  static String _resolveDoctorPhotoUrl(dynamic raw) {
    final value = raw?.toString() ?? '';
    if (value.isEmpty) return '';

    if (value.startsWith('http://') || value.startsWith('https://')) {
      if (value.contains('127.0.0.1')) {
        return value.replaceAll('127.0.0.1', '10.0.2.2');
      }
      return value;
    }

    // Clean leading slashes
    var path = value.trim();
    while (path.startsWith('/')) {
      path = path.substring(1);
    }

    if (path.startsWith('storage/')) {
      path = path.replaceFirst('storage/', '');
    }

    while (path.startsWith('/')) {
      path = path.substring(1);
    }

    return resolveStorageUrl(path);
  }

  // Dari JSON response Laravel API
  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    final hewan = json['hewan'] ?? {};
    final dokter = json['dokter'] ?? {};
    final pemilik = hewan['owner'] ?? {};

    return MedicalRecord(
      id: json['id'] ?? 0,
      namaHewan: hewan['nama_hewan'] ?? '-',
      jenisHewan: hewan['jenis'] ?? '-',
      rasHewan: hewan['ras'] ?? '-',
      umurHewan: hewan['umur']?.toString() ?? '-',
      beratHewan: hewan['berat'] != null
          ? double.tryParse(hewan['berat'].toString())
          : null,
      namaPemilik: pemilik['nama'] ?? '-',
      namaDokter: dokter['nama'] ?? '-',
      spesialisasiDokter: dokter['spesialisasi'] ?? 'Dokter Hewan',
      beratSaatItu: json['berat_saat_itu'] != null
          ? double.tryParse(json['berat_saat_itu'].toString())
          : null,
      tanggal: json['tanggal'] != null
          ? DateTime.tryParse(json['tanggal']) ?? DateTime.now()
          : DateTime.now(),
      diagnosa: json['diagnosa'] ?? 'Belum ada diagnosa',
      tindakan: json['tindakan'] ?? 'Belum ada tindakan',
      resep: json['resep'] ?? 'Belum ada resep',
      catatan: json['catatan'],
      fotoUrl: dokter['foto_url'] != null || dokter['foto'] != null || dokter['avatar'] != null
          ? _resolveDoctorPhotoUrl(dokter['foto_url'] ?? dokter['foto'] ?? dokter['avatar'])
          : null,
    );
  }
}
