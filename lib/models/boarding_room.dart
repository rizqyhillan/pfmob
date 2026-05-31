import 'dart:convert';

import 'model_utils.dart';

class BoardingRoom {
  final int id;
  final String namaKamar;
  final String paket;
  final int kapasitas;
  final int terisi;
  final int sisaKapasitas;
  final double hargaPerHari;
  final List<String> fasilitas;
  final bool tersedia;
  final List<String> fotoUrls;

  BoardingRoom({
    required this.id,
    required this.namaKamar,
    required this.paket,
    required this.kapasitas,
    required this.terisi,
    required this.sisaKapasitas,
    required this.hargaPerHari,
    required this.fasilitas,
    required this.tersedia,
    required this.fotoUrls,
  });

  String get fotoUrl => fotoUrls.isNotEmpty ? fotoUrls.first : '';

  static List<String> _resolvePhotoUrls(Map<String, dynamic> json) {
    final result = <String>[];

    void addOne(dynamic value) {
      final resolved = resolveStorageUrl(value).trim();
      if (resolved.isNotEmpty && !result.contains(resolved)) {
        result.add(resolved);
      }
    }

    void addMany(dynamic value) {
      if (value == null) return;

      if (value is List) {
        for (final item in value) {
          if (item is Map) {
            addOne(
              item['url'] ??
                  item['foto'] ??
                  item['foto_kamar'] ??
                  item['gambar'] ??
                  item['image'] ??
                  item['image_url'] ??
                  item['path'],
            );
          } else {
            addOne(item);
          }
        }
        return;
      }

      if (value is String) {
        final trimmed = value.trim();
        if (trimmed.isEmpty) return;

        if (trimmed.startsWith('[')) {
          try {
            final decoded = jsonDecode(trimmed);
            addMany(decoded);
            return;
          } catch (_) {}
        }

        if (trimmed.contains(',')) {
          for (final item in trimmed.split(',')) {
            addOne(item.trim());
          }
          return;
        }
      }

      addOne(value);
    }

    addMany(json['foto_urls']);
    addMany(json['fotoUrls']);
    addMany(json['fotos']);
    addMany(json['foto_kamar_list']);
    addMany(json['gambar_list']);
    addMany(json['images']);
    addMany(json['image_urls']);
    addMany(json['room_photos']);
    addMany(json['photos']);
    addMany(json['galeri']);
    addMany(json['gallery']);

    addOne(
      json['foto'] ??
          json['foto_kamar'] ??
          json['gambar'] ??
          json['image'] ??
          json['image_url'] ??
          json['imageUrl'],
    );

    return result;
  }

  factory BoardingRoom.fromJson(Map<String, dynamic> json) {
    final raw = json['fasilitas'];
    List<String> fasilitas = [];

    if (raw is List) {
      fasilitas = raw.map((e) => e.toString()).toList();
    }

    if (raw is String && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          fasilitas = decoded.map((e) => e.toString()).toList();
        }
      } catch (_) {
        fasilitas = raw
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    }

    return BoardingRoom(
      id: json['id'] ?? 0,
      namaKamar: json['nama_kamar'] ?? '-',
      paket: json['paket'] ?? '-',
      kapasitas: int.tryParse(json['kapasitas'].toString()) ?? 0,
      terisi: int.tryParse(json['terisi'].toString()) ?? 0,
      sisaKapasitas: int.tryParse(json['sisa_kapasitas'].toString()) ?? 0,
      hargaPerHari: double.tryParse(json['harga_per_hari'].toString()) ?? 0,
      fasilitas: fasilitas,
      tersedia: json['tersedia'] == true,
      fotoUrls: _resolvePhotoUrls(json),
    );
  }
}
