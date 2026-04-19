import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_mobile/components/components.dart';
import 'package:pos_mobile/configuration/configuration.dart';
import 'package:tabler_icons/tabler_icons.dart';
import 'package:provider/provider.dart';
import 'package:pos_mobile/providers/auth_provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final storeName = _storeNameController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || storeName.isEmpty || password.isEmpty) {
      mySnackBar(
        context: context,
        text: 'Harap isi semua bidang',
        status: ToastStatus.warning,
      );
      return;
    }

    if (password != confirmPassword) {
      mySnackBar(
        context: context,
        text: 'Password tidak cocok',
        status: ToastStatus.error,
      );
      return;
    }

    if (password.length < 6) {
      mySnackBar(
        context: context,
        text: 'Password minimal 6 karakter',
        status: ToastStatus.warning,
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    try {
      final success = await authProvider.register(
        email: email,
        password: password,
        fullName: name,
        storeName: storeName,
      );

      if (success && mounted) {
        mySnackBar(
          context: context,
          text: 'Registrasi berhasil!',
          status: ToastStatus.success,
        );
        Navigator.pop(context);
      } else if (mounted) {
        mySnackBar(
          context: context,
          text: 'Registrasi gagal. Coba lagi nanti.',
          status: ToastStatus.error,
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Terjadi kesalahan saat registrasi';
        if (e is AuthException) {
          errorMessage = e.message;
        } else if (e is PostgrestException) {
          errorMessage = 'Database Error: ${e.message}';
        } else {
          errorMessage = e.toString();
        }

        mySnackBar(
          context: context,
          text: errorMessage,
          status: ToastStatus.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Warna.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(TablerIcons.chevron_left, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Buat Akun Baru',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Lengkapi data di bawah untuk mendaftar sebagai Owner',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),

              myTextField(
                controller: _nameController,
                placeholder: 'Masukkan nama lengkap',
                labelText: 'Nama Lengkap',
              ),
              const SizedBox(height: 20),
              myTextField(
                controller: _emailController,
                placeholder: 'Email aktif Anda',
                labelText: 'Email Address',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              myTextField(
                controller: _storeNameController,
                placeholder: 'Contoh: Berkah Jaya Store',
                labelText: 'Nama Toko Anda',
              ),
              const SizedBox(height: 20),
              myTextField(
                controller: _passwordController,
                placeholder: 'Minimal 6 karakter',
                labelText: 'Password',
                obscureText: true,
              ),
              const SizedBox(height: 20),
              myTextField(
                controller: _confirmPasswordController,
                placeholder: 'Ulangi password',
                labelText: 'Konfirmasi Password',
                obscureText: true,
              ),
              const SizedBox(height: 40),

              MyButtonPrimary(
                onPressed: authProvider.isLoading ? () {} : () { _handleRegister(); },
                backgroundColor: Warna.primary,
                foregroundColor: Colors.white,
                child: authProvider.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Daftar Sekarang',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
              const SizedBox(height: 24),

              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sudah punya akun? ',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.grey[600],
                      ),
                    ),
                    BounceTapper(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Masuk Disini',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          color: Warna.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
