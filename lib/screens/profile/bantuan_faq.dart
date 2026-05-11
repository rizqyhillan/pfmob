import 'package:flutter/material.dart';

import '../../theme/tema_app.dart';

class BantuanFaqPage extends StatefulWidget {
  const BantuanFaqPage({super.key});

  @override
  State<BantuanFaqPage> createState() => _BantuanFaqPageState();
}

class _BantuanFaqPageState extends State<BantuanFaqPage> {
  final List<Map<String, String>> _faqs = [
    {
      'q': 'Bagaimana cara menambahkan hewan?',
      'a': 'Masuk ke menu My Pets, lalu tekan tombol + di kanan bawah dan isi data hewan peliharaanmu.',
    },
    {
      'q': 'Bagaimana cara melihat rekam medis?',
      'a': 'Buka menu Rekam Medis pada halaman profil. Data akan muncul jika hewanmu sudah pernah diperiksa oleh dokter.',
    },
    {
      'q': 'Bagaimana cara melihat riwayat transaksi?',
      'a': 'Buka menu Riwayat Transaksi di halaman profil. Semua transaksi yang terhubung dengan akunmu akan ditampilkan.',
    },
    {
      'q': 'Kenapa data saya tidak muncul?',
      'a': 'Pastikan kamu sudah login, koneksi internet aktif, dan akunmu memiliki data yang tersimpan di sistem PawPet.',
    },
    {
      'q': 'Bagaimana jika lupa password?',
      'a': 'Gunakan fitur Lupa Password di halaman login, lalu ikuti proses OTP melalui email.',
    },
  ];

  int? _openedIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Bantuan & FAQ',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.support_agent_rounded,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Butuh bantuan?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textDark,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Lihat pertanyaan umum seputar penggunaan aplikasi PawPet.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textMedium,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Pertanyaan Umum',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(_faqs.length, (index) {
            final faq = _faqs[index];
            final opened = _openedIndex == index;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.divider),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                ),
                child: ExpansionTile(
                  initiallyExpanded: opened,
                  onExpansionChanged: (value) {
                    setState(() {
                      _openedIndex = value ? index : null;
                    });
                  },
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  iconColor: AppColors.primary,
                  collapsedIconColor: AppColors.textLight,
                  title: Text(
                    faq['q']!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        faq['a']!,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: AppColors.textMedium,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.categoryBg1,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.primary,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Jika masih ada kendala, hubungi admin PawPet melalui layanan klinik.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textMedium,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}