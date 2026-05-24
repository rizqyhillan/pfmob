import 'package:flutter/material.dart';
import '../../services/servis_auth.dart';
import '../../theme/tema_app.dart';
import 'daftar_dokter.dart';
import 'paket_grooming.dart';
import 'paket_penitipan.dart';
import '../../widgets/user_avatar.dart';

class BookingContent extends StatelessWidget {
  const BookingContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildTitle(),
          const SizedBox(height: 24),
          _buildServiceCard(
            icon: Icons.medical_services_outlined,
            iconColor: Colors.white,
            iconBg: const Color(0xFF4A9B8E),
            title: 'Dokter Hewan',
            description: 'Konsultasi kesehatan, vaksinasi, dan pemeriksaan oleh tim veteriner profesional.',
            buttonText: 'Booking Sekarang',
            buttonColor: const Color(0xFF2C6E65),
            bgColor: const Color(0xFFE0F5F2),
            backgroundImage: 'assets/images/dokterHewan.jpg',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DaftarDokterScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildServiceCard(
            icon: Icons.content_cut_outlined,
            iconColor: Colors.white,
            iconBg: const Color(0xFF4CAF50),
            title: 'Grooming',
            description: 'Mandian spa, potong kuku, dan styling rambut.',
            buttonText: 'Pilih Paket',
            buttonColor: const Color(0xFF2E7D32),
            bgColor: const Color(0xFFE8F5E9),
            backgroundImage: 'assets/images/grooming.jpg',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PaketGroomingScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildServiceCard(
            icon: Icons.home_outlined,
            iconColor: Colors.white,
            iconBg: const Color(0xFFFF9800),
            title: 'Penitipan (Boarding)',
            description: 'Lingkungan aman dan nyaman seperti di rumah sendiri untuk anabul kesayangan saat Anda bepergian.',
            buttonText: 'Booking Sekarang',
            buttonColor: const Color(0xFFE65100),
            bgColor: const Color(0xFFFFF3E0),
            backgroundImage: 'assets/images/boarding.jpg',
            onTap: () => Navigator.push(
             context,
            MaterialPageRoute(builder: (_) => const PaketPenitipanScreen()),
  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final auth = AuthService();
    final isLoggedIn = auth.isLoggedIn;
    final displayName = auth.userName.trim().isNotEmpty
        ? auth.userName.trim()
        : 'User PawPet';

    return Row(
      children: [
        const UserAvatar(),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isLoggedIn ? 'PET OWNER' : 'WELCOME',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.textLight,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              isLoggedIn ? displayName : 'PawPet',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Waktunya Manjakan\nSahabat Bulu Anda',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textDark, height: 1.3),
        ),
        SizedBox(height: 8),
        Text(
          'Pilih layanan perawatan terbaik dengan\ntenaga ahli bersertifikat.',
          style: TextStyle(fontSize: 13, color: AppColors.textLight, fontWeight: FontWeight.w500, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildServiceCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String description,
    required String buttonText,
    required Color buttonColor,
    required Color bgColor,
    String imagePlaceholder = '', // ← tidak required lagi, default kosong
    VoidCallback? onTap,
    String? backgroundImage,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        image: backgroundImage != null
            ? DecorationImage(
                image: AssetImage(backgroundImage),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withValues(alpha: 0.55),
                  BlendMode.darken,
                ),
              )
            : null,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: backgroundImage != null ? Colors.white : AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: backgroundImage != null ? Colors.white70 : AppColors.textMedium,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: onTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: buttonColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          buttonText,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (imagePlaceholder.isNotEmpty) ...[
                const SizedBox(width: 12),
                Text(imagePlaceholder, style: const TextStyle(fontSize: 64)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}