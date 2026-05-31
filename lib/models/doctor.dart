import 'package:flutter/foundation.dart';

import 'model_utils.dart';

class Doctor {
  final int id;
  final String nama;
  final String spesialis;
  final String pengalaman;
  final double rating;
  final bool tersedia;
  final String? fotoUrl;

  Doctor({
    required this.id,
    required this.nama,
    required this.spesialis,
    required this.pengalaman,
    required this.rating,
    required this.tersedia,
    this.fotoUrl,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    final rawFoto = json['foto_url'] ?? json['fotoUrl'] ?? json['foto'] ?? json['avatar'] ?? json['image'];
    final doctor = Doctor(
      id: json['id'] ?? 0,
      nama: json['nama'] ?? '-',
      spesialis: json['spesialis'] ?? 'Dokter Hewan',
      pengalaman: json['pengalaman'] ?? '-',
      rating: double.tryParse(json['rating'].toString()) ?? 0,
      tersedia: json['tersedia'] == true,
      fotoUrl: rawFoto != null ? resolveStorageUrl(rawFoto) : null,
    );
    debugPrint('PAWPET_DEBUG: Doctor JSON = $json');
    debugPrint('PAWPET_DEBUG: Doctor photo = ${doctor.fotoUrl}');
    return doctor;
  }
}
