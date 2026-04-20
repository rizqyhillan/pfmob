import 'package:flutter/material.dart';
import '../theme/tema_app.dart';
import '../services/servis_auth.dart';
import 'login.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
                MaterialPageRoute(builder: (_) => const LoginScreen()),
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
          // Header dengan avatar
          SliverToBoxAdapter(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Background gradient
                Container(
                  height: 180,
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
                            icon: const Icon(Icons.edit_outlined,
                                color: Colors.white70, size: 22),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Avatar card — overlap
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
                                color: AppColors.primary.withOpacity(0.25),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text('🐱', style: TextStyle(fontSize: 44)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Spacer for avatar overlap
          const SliverToBoxAdapter(child: SizedBox(height: 74)),

          // Name & email
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
                const SizedBox(height: 16),
                // Stats row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.divider),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStat('3', 'Hewan', '🐾'),
                        _buildStatDivider(),
                        _buildStat('12', 'Booking', '📅'),
                        _buildStatDivider(),
                        _buildStat('5', 'Pesanan', '🛍️'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Menu items
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
                  _buildMenuCard([
                    _MenuItem(
                        Icons.person_outline,
                        'Edit Profil',
                        'Ubah nama, foto, dan info pribadi',
                        AppColors.categoryBg1,
                        AppColors.primary),
                    _MenuItem(
                        Icons.lock_outline,
                        'Ubah Password',
                        'Perbarui keamanan akunmu',
                        AppColors.categoryBg2,
                        const Color(0xFF2196F3)),
                    _MenuItem(
                        Icons.notifications_outlined,
                        'Notifikasi',
                        'Atur preferensi notifikasi',
                        AppColors.categoryBg3,
                        AppColors.accent),
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
                  _buildMenuCard([
                    _MenuItem(
                        Icons.help_outline,
                        'Bantuan & FAQ',
                        'Punya pertanyaan? Kami siap membantu',
                        AppColors.categoryBg4,
                        const Color(0xFF7C4DFF)),
                    _MenuItem(
                        Icons.shield_outlined,
                        'Kebijakan Privasi',
                        'Pelajari bagaimana data kamu digunakan',
                        AppColors.categoryBg1,
                        AppColors.primary),
                    _MenuItem(Icons.info_outline, 'Tentang Aplikasi',
                        'Versi 1.0.0', AppColors.categoryBg3, AppColors.accent),
                  ]),

                  const SizedBox(height: 20),

                  // Logout button
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

  Widget _buildStat(String value, String label, String emoji) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textLight,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 40,
      color: AppColors.divider,
    );
  }

  Widget _buildMenuCard(List<_MenuItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
                title: Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                subtitle: Text(
                  item.subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right,
                    color: AppColors.textLight, size: 20),
                onTap: () {},
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
  const _MenuItem(
      this.icon, this.title, this.subtitle, this.bgColor, this.iconColor);
}
