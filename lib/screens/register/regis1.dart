import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../../theme/tema_app.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import 'regis2.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _agreeTerms = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

void _lanjut() async {
  if (!_agreeTerms) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Kamu harus menyetujui syarat & ketentuan',
        ),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  if (_formKey.currentState!.validate()) {
    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/send-otp'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': _emailController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        if (!mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RegisterStep2Screen(
              name: _nameController.text.trim(),
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscure = false,
    VoidCallback? onToggleObscure,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.textLight),
          ),
          validator: validator,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                size: 16, color: AppColors.textDark),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
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

                    // Header
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(14)),
                        child: const Icon(Icons.pets,
                            color: Colors.white, size: 22),
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
                          Text('Bergabung bersama ribuan pet owner 🐾',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textLight,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ]),

                    const SizedBox(height: 24),
                    buildStepIndicator(currentStep: 1),
                    const SizedBox(height: 28),

                    _buildField(
                      controller: _nameController,
                      label: 'Nama Lengkap',
                      hint: 'Masukkan nama lengkap kamu',
                      icon: Icons.person_outline,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Nama wajib diisi' : null,
                    ),
                    _buildField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'Masukkan email kamu',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Email wajib diisi';
                        if (!v.contains('@')) return 'Email tidak valid';
                        return null;
                      },
                    ),
                    _buildField(
                      controller: _passwordController,
                      label: 'Password',
                      hint: 'Buat password (min. 6 karakter)',
                      icon: Icons.lock_outline,
                      validator: (v) {
                        if (v == null || v.isEmpty)
                          return 'Password wajib diisi';
                        if (v.length < 6) return 'Password minimal 6 karakter';
                        return null;
                      },
                    ),
                    _buildField(
                      controller: _confirmPasswordController,
                      label: 'Konfirmasi Password',
                      hint: 'Ulangi password kamu',
                      icon: Icons.lock_outline,
                      validator: (v) {
                        if (v == null || v.isEmpty)
                          return 'Konfirmasi password wajib diisi';
                        if (v != _passwordController.text)
                          return 'Password tidak cocok';
                        return null;
                      },
                    ),

                    // Terms checkbox
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: _agreeTerms,
                          onChanged: (v) =>
                              setState(() => _agreeTerms = v ?? false),
                          activeColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
                        ),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              text: 'Saya menyetujui ',
                              style: const TextStyle(
                                  color: AppColors.textLight,
                                  fontSize: 13,
                                  fontFamily: 'Nunito'),
                              children: [
                                TextSpan(
                                  text: 'Syarat & Ketentuan',
                                  style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Nunito'),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {},
                                ),
                                const TextSpan(text: ' dan '),
                                TextSpan(
                                  text: 'Kebijakan Privasi',
                                  style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Nunito'),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {},
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _lanjut,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Text('Lanjut →'),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Center(
                      child: RichText(
                        text: TextSpan(
                          text: 'Sudah punya akun? ',
                          style: const TextStyle(
                              color: AppColors.textLight,
                              fontSize: 14,
                              fontFamily: 'Nunito'),
                          children: [
                            TextSpan(
                              text: 'Masuk di sini',
                              style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  fontFamily: 'Nunito'),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Shared step indicator (dipakai oleh step 1, 2, 3) ───────────────────────

Widget buildStepIndicator({required int currentStep}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.categoryBg1,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.divider),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStep('1', 'Data Diri', currentStep >= 1),
        _buildStepLine(active: currentStep >= 2),
        _buildStep('2', 'Verifikasi', currentStep >= 2),
        _buildStepLine(active: currentStep >= 3),
        _buildStep('3', 'Selesai', currentStep >= 3),
      ],
    ),
  );
}

Widget _buildStep(String number, String label, bool isActive) {
  return Column(
    children: [
      Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.divider,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: isActive && int.parse(number) < 99
              ? Icon(
                  int.parse(number) == 3 ? Icons.check : null,
                  color: Colors.white,
                  size: 14,
                )
              : null,
        ),
      ),
      // fallback: always show number
      // (rebuilt below properly)
      const SizedBox(height: 4),
      Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          color: isActive ? AppColors.primary : AppColors.textLight,
        ),
      ),
    ],
  );
}

Widget _buildStepLine({bool active = false}) {
  return Expanded(
    child: Container(
      height: 2,
      margin: const EdgeInsets.only(bottom: 20, left: 4, right: 4),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : AppColors.divider,
        borderRadius: BorderRadius.circular(1),
      ),
    ),
  );
}
