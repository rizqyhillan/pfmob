import 'package:flutter/material.dart';
import '../../theme/tema_app.dart';
import '../../services/servis_auth.dart';
import 'medical_report_list.dart';
import 'shop_report.dart';
import 'edit_profil.dart';
import 'ubah_password.dart';
import 'bantuan_faq.dart';
import 'kebijakan_privasi.dart';
import 'tentang_aplikasi.dart';
import '../Home/dashboard.dart';


class ProfileScreen extends StatelessWidget {
  final bool showBackButton;

  const ProfileScreen({
    super.key,
    this.showBackButton = false,
  });

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.background,
        title: const Text(
          'Keluar Akun',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
            fontSize: 18,
          ),
        ),
        content: const Text(
          'Apakah kamu yakin ingin keluar dari akun PetCare?',
          style: TextStyle(
            color: AppColors.textLight,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Batal',
              style: TextStyle(
                color: AppColors.textLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              AuthService().logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const DashboardScreen(initialIndex: 0),
                ),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE57373),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 100,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primaryDark, AppColors.primary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                        child: Row(
                          children: [
                            if (showBackButton) ...[
                              GestureDetector(
                                onTap: () {
                                  if (Navigator.canPop(context)) {
                                    Navigator.pop(context);
                                  } else {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const DashboardScreen(initialIndex: 0),
                                      ),
                                      (route) => false,
                                    );
                                  }
                                },
                                child: Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],
                            const Text(
                              'Profil Saya',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(
                                Icons.edit_outlined,
                                color: Colors.white70,
                                size: 22,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const EditProfilPage(),
                                  ),
                                ).then((updated) {
                                  if (!context.mounted) return;
                                  if (updated == true) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ProfileScreen(showBackButton: showBackButton),
                                      ),
                                    );
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -60,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Column(
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryLight,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.25),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                            child: ClipOval(
                              child: AuthService().userPhoto.isNotEmpty
                                  ? Image.network(
                                      AuthService().userPhoto,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.person_rounded,
                                        color: AppColors.primary,
                                        size: 44,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.person_rounded,
                                      color: AppColors.primary,
                                      size: 44,
                                    ),
                            ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 74)),

          SliverToBoxAdapter(
            child: Column(
              children: [
                Text(
                  AuthService().userName.isNotEmpty
                      ? AuthService().userName
                      : 'Pengguna PetCare',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AuthService().userEmail.isNotEmpty
                      ? AuthService().userEmail
                      : '-',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Akun',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textLight,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildMenuCard(context, [

                    _MenuItem(
                      icon: Icons.person_outline,
                      title: 'Edit Profil',
                      subtitle: 'Ubah nama, foto, dan info pribadi',
                      bgColor: AppColors.categoryBg1,
                      iconColor: AppColors.primary,
                      onTap: (ctx) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EditProfilPage(),
                          ),
                        ).then((updated) {
                            if (!context.mounted) return;
                          if (updated == true) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProfileScreen(showBackButton: showBackButton),
                              ),
                            );
                          }
                        });
                      },
                    ),

                    // ✅ SUDAH TERSAMBUNG ke medical_report.dart
                    _MenuItem(
                      icon: Icons.insert_drive_file_outlined,
                      title: 'Laporan',
                      subtitle: 'Lihat dan kelola laporanmu',
                      bgColor: AppColors.categoryBg1,
                      iconColor: AppColors.primary,
                      onTap: (ctx) {
                        Navigator.push(ctx, MaterialPageRoute(
                          builder: (_) => const MedicalReportPage(),
                        ));
                      },
                    ),

                    _MenuItem(
                      icon: Icons.shopping_basket_outlined,
                      title: 'Riwayat Belanja',
                      subtitle: 'Lihat riwayat belanjamu',
                      bgColor: AppColors.categoryBg1,
                      iconColor: AppColors.primary,
                      onTap: (ctx) {
                        Navigator.push(ctx, MaterialPageRoute(
                          builder: (_) => const ShopReportPage(),
                        ));
                      },
                    ),

                    _MenuItem(
                      icon: Icons.lock_outline,
                      title: 'Ubah Password',
                      subtitle: 'Perbarui keamanan akunmu',
                      bgColor: AppColors.categoryBg2,
                      iconColor: const Color(0xFF2196F3),
                      onTap: (ctx) {
                        Navigator.push(ctx, MaterialPageRoute(
                          builder: (_) => const UbahPasswordPage(),
                        ));
                      },
                    ),

                  ]),

                  const SizedBox(height: 20),

                  const Text(
                    'Lainnya',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textLight,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildMenuCard(context, [

                    _MenuItem(
                      icon: Icons.help_outline,
                      title: 'Bantuan & FAQ',
                      subtitle: 'Punya pertanyaan? Kami siap membantu',
                      bgColor: AppColors.categoryBg4,
                      iconColor: const Color(0xFF7C4DFF),
                      onTap: (ctx) {
                        Navigator.push(ctx, MaterialPageRoute(
                          builder: (_) => const BantuanFaqPage(),
                        ));
                      },
                    ),

                    _MenuItem(
                      icon: Icons.shield_outlined,
                      title: 'Kebijakan Privasi',
                      subtitle: 'Pelajari bagaimana data kamu digunakan',
                      bgColor: AppColors.categoryBg1,
                      iconColor: AppColors.primary,
                      onTap: (ctx) {
                        Navigator.push(ctx, MaterialPageRoute(
                          builder: (_) => const KebijakanPrivasiPage(),
                        ));
                      },
                    ),

                    _MenuItem(
                      icon: Icons.info_outline,
                      title: 'Tentang Aplikasi',
                      subtitle: 'Versi 1.0.0',
                      bgColor: AppColors.categoryBg3,
                      iconColor: AppColors.accent,
                      onTap: (ctx) {
                        Navigator.push(ctx, MaterialPageRoute(
                          builder: (_) => const TentangAplikasiPage(),
                        ));
                      },
                    ),

                  ]),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showLogoutDialog(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFE57373),
                        side: const BorderSide(
                            color: Color(0xFFFFCDD2), width: 1.5),
                        backgroundColor: const Color(0xFFFFF5F5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.logout, size: 20),
                      label: const Text(
                        'Keluar dari Akun',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, List<_MenuItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          return Column(
            children: [
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: item.bgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.icon, color: item.iconColor, size: 20),
                ),
                title: Text(item.title,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark)),
                subtitle: Text(item.subtitle,
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w500)),
                trailing: const Icon(Icons.chevron_right,
                    color: AppColors.textLight, size: 20),
                onTap: () => item.onTap?.call(context),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              ),
              if (i < items.length - 1)
                Divider(
                    height: 1,
                    indent: 72,
                    endIndent: 16,
                    color: AppColors.divider),
            ],
          );
        }),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color bgColor;
  final Color iconColor;
  final void Function(BuildContext ctx)? onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.bgColor,
    required this.iconColor,
    this.onTap,
  });
}