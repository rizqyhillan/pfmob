import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import '../../theme/tema_app.dart';
import '../../viewmodels/auth_viewmodel.dart';
import 'regis1.dart' show buildStepIndicator;
import 'regis3.dart';

class RegisterStep2Screen extends StatefulWidget {
  final String name;
  final String email;
  final String password;

  const RegisterStep2Screen({
    super.key,
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  State<RegisterStep2Screen> createState() => _RegisterStep2ScreenState();
}

class _RegisterStep2ScreenState extends State<RegisterStep2Screen>
    with SingleTickerProviderStateMixin {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  int _countdown = 60;
  Timer? _timer;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _countdown = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown == 0) {
        t.cancel();
      } else {
        setState(() => _countdown--);
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  void _onChanged(int index, String value) {
    if (value.length == 1 && index < 3) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

Future<void> _verify() async {
  if (_otpCode.length < 4) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Masukkan 4 digit kode verifikasi'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  final authViewModel = context.read<AuthViewModel>();

  final success = await authViewModel.verifyOtpAndRegister(
    nama: widget.name,
    email: widget.email,
    password: widget.password,
    otp: _otpCode,
  );

  if (!mounted) return;

  if (success) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => RegisterStep3Screen(
          name: widget.name,
        ),
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(authViewModel.errorMessage ?? 'Verifikasi gagal'),
        backgroundColor: Colors.red,
      ),
    );
  }
}


Future<void> _resendOtp() async {
  final authViewModel = context.read<AuthViewModel>();

  final success = await authViewModel.sendOtp(
    email: widget.email,
  );

  if (!mounted) return;

  if (success) {
    _startCountdown();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kode OTP berhasil dikirim ulang'),
        backgroundColor: Colors.green,
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(authViewModel.errorMessage ?? 'Gagal mengirim ulang OTP'),
        backgroundColor: Colors.red,
      ),
    );
  }
}


  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final name = parts[0];
    final domain = parts[1];
    if (name.length <= 2) return '${name[0]}***@$domain';
    return '${name[0]}${'*' * (name.length - 2)}${name[name.length - 1]}@$domain';
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

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
                        Text('Verifikasi email kamu 🐾',
                            style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textLight,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ]),

                  const SizedBox(height: 24),
                  buildStepIndicator(currentStep: 2),
                  const SizedBox(height: 32),

                  // Illustration
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.categoryBg1,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.divider, width: 2),
                      ),
                      child: const Center(
                          child: Text('📧', style: TextStyle(fontSize: 46))),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Center(
                    child: Text(
                      'Halo, ${widget.name.split(' ').first}! 👋',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      'Kode verifikasi 4 digit telah dikirim ke\n${_maskEmail(widget.email)}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // OTP boxes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(4, (i) => _buildOtpBox(i)),
                  ),

                  const SizedBox(height: 28),

                  // Countdown / resend
                  Center(
                    child: _countdown > 0
                        ? RichText(
                            text: TextSpan(
                              text: 'Kirim ulang kode dalam ',
                              style: const TextStyle(
                                  color: AppColors.textLight,
                                  fontSize: 14,
                                  fontFamily: 'Nunito'),
                              children: [
                                TextSpan(
                                  text:
                                      '0:${_countdown.toString().padLeft(2, '0')}',
                                  style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w800,
                                      fontFamily: 'Nunito'),
                                ),
                              ],
                            ),
                          )
                        : TextButton(
                            onPressed: authViewModel.isLoading ? null : _resendOtp,
                            child: const Text(
                              'Kirim Ulang Kode',
                              style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14),
                            ),
                          ),
                  ),

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: authViewModel.isLoading ? null : _verify,
                      child: authViewModel.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text('Verifikasi & Buat Akun'),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    final isFilled = _controllers[index].text.isNotEmpty;
    return SizedBox(
      width: 48,
      height: 56,
      child: TextFormField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: isFilled ? AppColors.categoryBg1 : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: isFilled ? AppColors.primary : AppColors.divider,
              width: isFilled ? 2 : 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: isFilled ? AppColors.primary : AppColors.divider,
              width: isFilled ? 2 : 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (v) => _onChanged(index, v),
      ),
    );
  }
}
