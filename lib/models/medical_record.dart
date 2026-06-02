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

  static String _text(dynamic value, {String fallback = '-'}) {
    final text = value?.toString().trim() ?? '';
    if (text.isEmpty || text.toLowerCase() == 'null') return fallback;
    return text;
  }

  static double? _double(dynamic value) {
    if (value == null) return null;
    return double.tryParse(value.toString());
  }

  static Map<String, dynamic> _map(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  static String _resolveDoctorPhotoUrl(dynamic raw) {
    final value = raw?.toString().trim() ?? '';
    if (value.isEmpty || value.toLowerCase() == 'null') return '';

    if (value.startsWith('http://') || value.startsWith('https://')) {
      if (value.contains('127.0.0.1')) {
        return value.replaceAll('127.0.0.1', '10.0.2.2');
      }
      return value;
    }

    var path = value;
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

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    final hewan = _map(json['hewan']);
    final dokter = _map(json['dokter']);
    final pemilik = _map(hewan['owner']);

    final rawFotoDokter = json['foto_dokter_url'] ??
        dokter['foto_url'] ??
        dokter['foto'] ??
        dokter['avatar'];
    final fotoDokter = _resolveDoctorPhotoUrl(rawFotoDokter);

    return MedicalRecord(
      id: json['id'] ?? 0,

      // Support 2 format API:
      // 1) flat: nama_hewan, nama_dokter, jenis_hewan, dst.
      // 2) nested: hewan.nama_hewan, dokter.nama, hewan.owner.nama, dst.
      namaHewan: _text(json['nama_hewan'] ?? hewan['nama_hewan']),
      jenisHewan: _text(json['jenis_hewan'] ?? hewan['jenis']),
      rasHewan: _text(json['ras_hewan'] ?? hewan['ras']),
      umurHewan: _text(json['umur_hewan'] ?? hewan['umur']),
      beratHewan: _double(json['berat_hewan'] ?? hewan['berat']),
      namaPemilik: _text(json['nama_pemilik'] ?? pemilik['nama']),
      namaDokter: _text(json['nama_dokter'] ?? dokter['nama']),
      spesialisasiDokter: _text(
        json['spesialisasi_dokter'] ?? dokter['spesialisasi'],
        fallback: 'Dokter Hewan',
      ),
      beratSaatItu: _double(json['berat_saat_itu']),
      tanggal: json['tanggal'] != null
          ? DateTime.tryParse(json['tanggal'].toString()) ?? DateTime.now()
          : DateTime.now(),
      diagnosa: _text(json['diagnosa'], fallback: 'Belum ada diagnosa'),
      tindakan: _text(json['tindakan'], fallback: 'Belum ada tindakan'),
      resep: _text(json['resep'], fallback: 'Belum ada resep'),
      catatan: _text(json['catatan'], fallback: '').isEmpty
          ? null
          : _text(json['catatan'], fallback: ''),
      fotoUrl: fotoDokter.isEmpty ? null : fotoDokter,
    );
  }
}
