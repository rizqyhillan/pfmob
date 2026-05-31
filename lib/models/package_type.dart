import 'dart:convert';

class PackageType {
  final int id;
  final String name;
  final String label;
  final String description;
  final String hargaPerMalam;
  final List<String> fasilitas;

  PackageType({
    required this.id,
    required this.name,
    required this.label,
    required this.description,
    required this.hargaPerMalam,
    required this.fasilitas,
  });

  factory PackageType.fromJson(Map<String, dynamic> json) {
    List<String> parseFasilitas = [];
    if (json['fasilitas'] != null) {
      if (json['fasilitas'] is List) {
        parseFasilitas = List<String>.from(json['fasilitas']);
      } else if (json['fasilitas'] is String) {
        // Jika masih string JSON
        try {
          final decoded = jsonDecode(json['fasilitas']);
          if (decoded is List) parseFasilitas = List<String>.from(decoded);
        } catch (_) {}
      }
    }

    return PackageType(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      label: json['label'] ?? '',
      description: json['description'] ?? '',
      hargaPerMalam: json['harga_per_malam']?.toString() ?? '0',
      fasilitas: parseFasilitas,
    );
  }
}
