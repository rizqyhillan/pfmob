class DoctorScheduleItem {
  final int id;
  final int idDokter;
  final String hari;
  final String jamMulai;
  final String jamSelesai;

  DoctorScheduleItem({
    required this.id,
    required this.idDokter,
    required this.hari,
    required this.jamMulai,
    required this.jamSelesai,
  });

  factory DoctorScheduleItem.fromJson(Map<String, dynamic> json) => DoctorScheduleItem(
        id: json['id'] ?? 0,
        idDokter: json['id_dokter'] ?? 0,
        hari: json['hari'] ?? '-',
        jamMulai: json['jam_mulai'] ?? '',
        jamSelesai: json['jam_selesai'] ?? '',
      );
}
