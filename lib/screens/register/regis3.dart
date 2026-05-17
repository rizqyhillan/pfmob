import 'package:flutter/material.dart';
import '../../theme/tema_app.dart';
import 'regis1.dart' show buildStepIndicator;
import '../Home/dashboard.dart';

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
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(14)),
                      child: const Icon(Icons.pets, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Buat Akun Baru', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                        Text('Pendaftaran selesai!', style: TextStyle(fontSize: 13, color: AppColors.textLight, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16), // ← dikurangi dari 24
                buildStepIndicator(currentStep: 3),
                const SizedBox(height: 8), // ← dikurangi jaraknya

                // Konten tengah + tombol bawah
                Expanded(
                  child: Column(
                    children: [
                      // Konten center
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(height: 90), // ← ditambahkan untuk memberi jarak antara step indicator dan animasi
                            ScaleTransition(
                              scale: _scaleAnim,
                              child: Container(
                                width: 120, height: 120,
                                decoration: BoxDecoration(
                                  color: AppColors.accentLight,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.accent.withOpacity(0.3), width: 3),
                                  boxShadow: [BoxShadow(color: AppColors.accent.withOpacity(0.2), blurRadius: 24, offset: const Offset(0, 8))],
                                ),
                                child: const Center(
                                  child: Icon(Icons.check_circle_rounded, color: AppColors.accent, size: 64),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Selamat Bergabung, ${widget.name.split(' ').first}!',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textDark, letterSpacing: -0.3),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Akun PawPet kamu berhasil dibuat.\nSekarang kamu bisa mulai merawat\nhewan kesayanganmu!',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 15, color: AppColors.textLight, fontWeight: FontWeight.w500, height: 1.6),
                            ),
                          ],
                        ),
                      ),

                      // Tombol di paling bawah
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => const DashboardScreen(initialIndex: 0)),
                              (route) => false,
                            );
                          },
                          child: const Text('Masuk ke Akun'),
                        ),
                      ),
                      const SizedBox(height: 50),
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
}