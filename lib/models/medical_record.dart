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

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  static String _string(dynamic value, {String fallback = '-'}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  static double? _doubleOrNull(dynamic value) {
    if (value == null) return null;
    return double.tryParse(value.toString());
  }

  static String? _resolveDoctorPhotoUrl(dynamic raw) {
    final value = raw?.toString().trim() ?? '';
    if (value.isEmpty) return null;
    return resolveStorageUrl(value);
  }

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    final hewan = _asMap(json['hewan']);
    final dokter = _asMap(json['dokter']);
    final pemilik = _asMap(hewan['owner']);

    return MedicalRecord(
      id: int.tryParse((json['id'] ?? 0).toString()) ?? 0,
      namaHewan: _string(json['nama_hewan'] ?? hewan['nama_hewan']),
      jenisHewan: _string(json['jenis_hewan'] ?? hewan['jenis']),
      rasHewan: _string(json['ras_hewan'] ?? hewan['ras']),
      umurHewan: _string(json['umur_hewan'] ?? hewan['umur']),
      beratHewan: _doubleOrNull(json['berat_hewan'] ?? hewan['berat']),
      namaPemilik: _string(json['nama_pemilik'] ?? pemilik['nama']),
      namaDokter: _string(json['nama_dokter'] ?? dokter['nama']),
      spesialisasiDokter: _string(
        json['spesialisasi_dokter'] ?? dokter['spesialisasi'],
        fallback: 'Dokter Hewan',
      ),
      beratSaatItu: _doubleOrNull(json['berat_saat_itu']),
      tanggal: json['tanggal'] != null
          ? DateTime.tryParse(json['tanggal'].toString()) ?? DateTime.now()
          : DateTime.now(),
      diagnosa: _string(json['diagnosa'], fallback: 'Belum ada diagnosa'),
      tindakan: _string(json['tindakan'], fallback: 'Belum ada tindakan'),
      resep: _string(json['resep'], fallback: 'Belum ada resep'),
      catatan: json['catatan']?.toString(),
      fotoUrl: _resolveDoctorPhotoUrl(
        json['foto_dokter'] ?? dokter['foto_url'] ?? dokter['foto'] ?? dokter['avatar'],
      ),
    );
  }
}
