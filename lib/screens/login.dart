import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../theme/tema_app.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'register/regis1.dart';
import 'lupa_pass.dart';
import 'Home/dashboard.dart';
class LoginScreen extends StatefulWidget {
  final bool redirectToProfile;
  const LoginScreen({super.key, this.redirectToProfile = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
            CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final authViewModel = context.read<AuthViewModel>();

    final success = await authViewModel.login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardScreen(
            initialIndex: widget.redirectToProfile ? 4 : 0,
          ),
        ),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authViewModel.errorMessage ?? 'Email atau password salah',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          onTap: () => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (_) => const DashboardScreen(initialIndex: 0)),
            (route) => false,
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.categoryBg1,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Konten utama
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),

                        // Logo & Header
                        Center(
                          child: Column(
                            children: [
                              SvgPicture.asset('assets/images/PawPetlogo.svg',
                                  width: 150),
                              const SizedBox(height: 10),
                              const Text(
                                'LOGIN',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textDark,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Email
                        const Text(
                          'Email',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: 'Masukkan email kamu',
                            prefixIcon: Icon(Icons.email_outlined,
                                color: AppColors.textLight),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              { return 'Email wajib diisi'; }
                            if (!v.contains('@')) return 'Email tidak valid';
                            return null;
                          },
                        ),

                        const SizedBox(height: 18),

                        // Password
                        const Text(
                          'Password',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: 'Masukkan password kamu',
                            prefixIcon: const Icon(Icons.lock_outline,
                                color: AppColors.textLight),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.textLight,
                              ),
                              onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              { return 'Password wajib diisi'; }
                            if (v.length < 6)
                              { return 'Password minimal 6 karakter'; } 
                            return null;
                          },
                        ),

                        const SizedBox(height: 10),

                        // Lupa password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const ForgotPasswordScreen()),
                            ),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Lupa password?',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Tombol login
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: authViewModel.isLoading ? null : _login,
                            child: authViewModel.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Masuk'),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Daftar
                        Center(
                          child: RichText(
                            text: TextSpan(
                              text: 'Belum punya akun? ',
                              style: const TextStyle(
                                color: AppColors.textLight,
                                fontSize: 14,
                                fontFamily: 'Nunito',
                              ),
                              children: [
                                TextSpan(
                                  text: 'Daftar sekarang',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    fontFamily: 'Nunito',
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  const RegisterScreen()),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 150),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}