import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/api_service.dart';
import '../../theme/tema_app.dart';
import '../../viewmodels/auth_viewmodel.dart';

class EditProfilPage extends StatefulWidget {
  const EditProfilPage({super.key});

  @override
  State<EditProfilPage> createState() => _EditProfilPageState();
}

class _EditProfilPageState extends State<EditProfilPage> {
  final _formKey = GlobalKey<FormState>();

  File? _fotoFile;
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _noHpController = TextEditingController();
  final _alamatController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    final authViewModel = context.read<AuthViewModel>();
    _namaController.text = authViewModel.userName;
    _emailController.text = authViewModel.userEmail;

    _loadProfile();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _noHpController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await ApiService.getProfile();

      if (!mounted) return;

      _namaController.text = profile.nama;
      _emailController.text = profile.email;
      _noHpController.text = profile.noHp;
      _alamatController.text = profile.alamat;
    } catch (e) {
      if (!mounted) return;
      _showSnack(e.toString().replaceAll('Exception: ', ''), Colors.red);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pilihFoto() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
      maxWidth: 1200,
    );
  
    if (picked == null) return;
  
    setState(() {
      _fotoFile = File(picked.path);
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final nama = _namaController.text.trim();
    final email = _emailController.text.trim();
    final noHp = _noHpController.text.trim();
    final alamat = _alamatController.text.trim();

    setState(() => _isSaving = true);

    try {
      final profile = await ApiService.updateProfile(
        nama: nama,
        email: email,
        noHp: noHp.isEmpty ? null : noHp,
        alamat: alamat.isEmpty ? null : alamat,
        fotoFile: _fotoFile,
      );

      await context.read<AuthViewModel>().updateLocalProfile(
        name: profile.nama,
        email: profile.email,
        photo: profile.foto,
      );

      if (!mounted) return;

      _showSnack('Profil berhasil diperbarui', AppColors.accent);
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showSnack(e.toString().replaceAll('Exception: ', ''), Colors.red);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showSnack(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _input({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hint,
    bool readOnly = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.primary),
            filled: true,
            fillColor: readOnly ? AppColors.background : Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        title: const Text(
          'Edit Profil',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _isSaving ? null : _pilihFoto,
                      child: Stack(
                        children: [
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryLight,
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.20),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: _fotoFile != null
                                  ? Image.file(
                                      _fotoFile!,
                                      fit: BoxFit.cover,
                                    )
                                  : context.watch<AuthViewModel>().userPhoto.isNotEmpty
                                      ? Image.network(
                                          context.watch<AuthViewModel>().userPhoto,
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
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    _input(
                      label: 'Nama Lengkap',
                      controller: _namaController,
                      icon: Icons.person_outline,
                      hint: 'Masukkan nama lengkap',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nama wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _input(
                      label: 'Email',
                      controller: _emailController,
                      icon: Icons.email_outlined,
                      readOnly: true,
                    ),
                    const SizedBox(height: 16),

                    _input(
                      label: 'Nomor HP',
                      controller: _noHpController,
                      icon: Icons.phone_outlined,
                      hint: 'Contoh: 081234567890',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),

                    _input(
                      label: 'Alamat',
                      controller: _alamatController,
                      icon: Icons.location_on_outlined,
                      hint: 'Masukkan alamat',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor: AppColors.textLight,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Simpan Perubahan',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}