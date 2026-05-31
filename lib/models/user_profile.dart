class UserProfile {
  final int id;
  final String nama;
  final String email;
  final String noHp;
  final String alamat;
  final String foto;

  UserProfile({
    required this.id,
    required this.nama,
    required this.email,
    required this.noHp,
    required this.alamat,
    required this.foto,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: int.tryParse(json['id'].toString()) ?? 0,
      nama: (json['nama'] ?? json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      noHp: (json['no_hp'] ?? '').toString(),
      alamat: (json['alamat'] ?? '').toString(),
      foto: (json['foto'] ?? '').toString(),
    );
  }
}
