import 'package:flutter/material.dart';
import '../../theme/tema_app.dart';
import 'regis1.dart' show buildStepIndicator;
import '../login.dart';

class RegisterStep3Screen extends StatefulWidget {
  final String name;

  const RegisterStep3Screen({super.key, required this.name});

  @override
  State<RegisterStep3Screen> createState() => _RegisterStep3ScreenState();
}

class _RegisterStep3ScreenState extends State<RegisterStep3Screen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // Tidak ada tombol back — user harus lewat tombol di bawah
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // Header
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(14)),
                    child:
                        const Icon(Icons.pets, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Buat Akun Baru',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark)),
                      Text('Pendaftaran selesai! 🐾',
                          style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textLight,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ]),

                const SizedBox(height: 24),
                buildStepIndicator(currentStep: 3),

                // Konten utama — center secara vertikal di sisa ruang
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animasi checkmark
                      ScaleTransition(
                        scale: _scaleAnim,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.accentLight,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.accent.withOpacity(0.3),
                                width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accent.withOpacity(0.2),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(Icons.check_circle_rounded,
                                color: AppColors.accent, size: 64),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      Text(
                        'Selamat, ${widget.name.split(' ').first}! 🎉',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Akun PetCare kamu berhasil dibuat.\nSekarang kamu bisa mulai merawat\nhewan kesayanganmu! 🐾',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.textLight,
                          fontWeight: FontWeight.w500,
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Info card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
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
                          children: [
                            _buildPerk(
                                '🛍️', 'Belanja produk pet care terbaik'),
                            const SizedBox(height: 12),
                            _buildPerk(
                                '📅', 'Booking grooming & vet dengan mudah'),
                            const SizedBox(height: 12),
                            _buildPerk(
                                '🐾', 'Pantau kesehatan hewan peliharaanmu'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Tombol kembali ke login
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const LoginScreen()),
                              (route) => false,
                            );
                          },
                          child: const Text('Masuk ke Akun'),
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPerk(String emoji, String text) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ),
        const Icon(Icons.check, color: AppColors.accent, size: 18),
      ],
    );
  }
}
