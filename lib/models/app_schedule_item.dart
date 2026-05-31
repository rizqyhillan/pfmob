class AppScheduleItem {
  final int id;
  final String type;
  final String title;
  final String subtitle;
  final String date;
  final String time;
  final String status;
  final String emoji;
  final String detailDateLabel;
  final String priceLabel;
  final String paymentNote;
  final Map<String, dynamic> raw;

  AppScheduleItem({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.time,
    required this.status,
    required this.emoji,
    required this.detailDateLabel,
    required this.priceLabel,
    required this.paymentNote,
    required this.raw,
  });

  bool get isHistory {
    final s = status.toLowerCase();
    return s == 'selesai' || s == 'batal' || s == 'dibatalkan' || s == 'cancelled';
  }

  bool get canCancel => status.toLowerCase() == 'pending';
  bool get canReschedule => status.toLowerCase() == 'pending';

  String get serviceTypeLabel {
    switch (type) {
      case 'doctor':
        return 'Dokter';
      case 'grooming':
        return 'Grooming';
      case 'boarding':
        return 'Penitipan';
      default:
        return 'Booking';
    }
  }

  factory AppScheduleItem.fromDoctorJson(Map<String, dynamic> json) {
    final petName = json['nama_hewan']?.toString() ?? '-';
    final petType = json['jenis_hewan']?.toString() ?? '-';
    final doctorName = json['nama_dokter']?.toString() ?? '-';

    return AppScheduleItem(
      id: int.tryParse(json['id'].toString()) ?? 0,
      type: 'doctor',
      title: json['nama_layanan']?.toString() ?? 'Konsultasi Dokter',
      subtitle: '$petName • $petType • drh. $doctorName',
      date: json['tanggal_booking']?.toString() ?? '-',
      time: _shortTime(json['jam_booking']?.toString()),
      status: json['status']?.toString() ?? 'pending',
      emoji: '🩺',
      detailDateLabel: 'Tanggal booking',
      priceLabel: _formatCurrency(json['estimasi_biaya'] ?? json['total_biaya']),
      paymentNote: json['payment_note']?.toString() ?? 'Pembayaran dilakukan di lokasi setelah layanan selesai.',
      raw: json,
    );
  }

  factory AppScheduleItem.fromBoardingJson(Map<String, dynamic> json) {
    final petName = json['nama_hewan']?.toString() ?? '-';
    final petType = json['jenis_hewan']?.toString() ?? '-';
    final roomName = json['nama_kamar']?.toString() ?? '-';

    return AppScheduleItem(
      id: int.tryParse(json['id'].toString()) ?? 0,
      type: 'boarding',
      title: 'Penitipan $roomName',
      subtitle: '$petName • $petType',
      date: json['tanggal_masuk']?.toString() ?? '-',
      time: 'Check-in',
      status: json['status']?.toString() ?? 'pending',
      emoji: '🏠',
      detailDateLabel: 'Check-in',
      priceLabel: _formatCurrency(json['estimasi_biaya'] ?? json['total_biaya']),
      paymentNote: json['payment_note']?.toString() ?? 'Pembayaran dilakukan di lokasi saat check-in atau setelah penitipan selesai.',
      raw: json,
    );
  }

  factory AppScheduleItem.fromGroomingJson(Map<String, dynamic> json) {
  final petName = json['nama_hewan']?.toString() ?? '-';
  final petType = json['jenis_hewan']?.toString() ?? '-';
  final packageName = json['nama_paket']?.toString() ?? 'Grooming';

    return AppScheduleItem(
      id: int.tryParse(json['id'].toString()) ?? 0,
      type: 'grooming',
      title: packageName,
      subtitle: '$petName • $petType',
      date: json['tanggal_grooming']?.toString() ?? '-',
      time: _shortTime(json['waktu_grooming']?.toString()),
      status: json['status']?.toString() ?? 'pending',
      emoji: '✂️',
      detailDateLabel: 'Tanggal grooming',
      priceLabel: _formatCurrency(json['estimasi_biaya'] ?? json['total_biaya']),
      paymentNote: json['payment_note']?.toString() ?? 'Pembayaran dilakukan di lokasi setelah layanan selesai.',
      raw: json,
    );
  }

  static String _shortTime(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    if (raw.length >= 5) return raw.substring(0, 5);
    return raw;
  }

  static String _formatCurrency(dynamic value) {
    final amount = double.tryParse((value ?? 0).toString()) ?? 0;
    final rounded = amount.round().toString();
    final formatted = rounded.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return 'Rp $formatted';
  }
}
