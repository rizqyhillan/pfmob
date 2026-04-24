import 'package:flutter/material.dart';
import '../theme/tema_app.dart';
import 'dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _introController;
  late AnimationController _fadeOutController;

  late Animation<double> _fadeIn;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeOut;

  @override
  void initState() {
    super.initState();

    // Controller untuk intro (slide + fade in)
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _introController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _introController, curve: Curves.bounceOut),
    );

    // Controller terpisah khusus fade out
    _fadeOutController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeOutController, curve: Curves.easeInOut),
    );

    _runAnimations();
  }

  void _runAnimations() async {
    // Logo naik dari bawah + bounce (sekali saja)
    await _introController.forward();

    // Diam sebentar
    await Future.delayed(const Duration(milliseconds: 800));

    // Fade out smooth
    await _fadeOutController.forward();

    // Pindah ke dashboard
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const DashboardScreen(),
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 100),
        ),
      );
    }
  }

  @override
  void dispose() {
    _introController.dispose();
    _fadeOutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: FadeTransition(
          opacity: _fadeOut,
          child: FadeTransition(
            opacity: _fadeIn,
            child: SlideTransition(
              position: _slideAnimation,
              child: Image.asset(
                'assets/images/LOGO_PawPet.PNG',
                width: 220,
              ),
            ),
          ),
        ),
      ),
    );
  }
}