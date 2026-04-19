import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_mobile/components/components.dart';
import 'package:pos_mobile/configuration/configuration.dart';
import 'package:pos_mobile/pages/auth/register_page.dart';
import 'package:tabler_icons/tabler_icons.dart';
import 'package:provider/provider.dart';
import 'package:pos_mobile/providers/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      mySnackBar(
        context: context,
        text: 'Email dan password harus diisi',
        status: ToastStatus.warning,
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    try {
      final success = await authProvider.login(email, password);

      if (!success && mounted) {
        mySnackBar(
          context: context,
          text: 'Login gagal. Silakan periksa kembali akun Anda.',
          status: ToastStatus.error,
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Terjadi kesalahan saat login';
        if (e is AuthException) {
          errorMessage = e.message;
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo/Header
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Warna.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          TablerIcons.device_mobile,
                          size: 48,
                          color: Warna.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'POS Mobile',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Warna.primary,
                        ),
                      ),
                      Text(
                        'Kelola bisnis Anda dengan mudah',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                Text(
                  'Selamat Datang',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Silakan login untuk melanjutkan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 40),

                myTextField(
                  controller: _emailController,
                  placeholder: 'Email Anda',
                  labelText: 'Email Address',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                myTextField(
                  controller: _passwordController,
                  placeholder: 'Masukkan password',
                  labelText: 'Password',
                  obscureText: true,
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      'Lupa Password?',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Warna.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                MyButtonPrimary(
                  onPressed: authProvider.isLoading
                      ? () {}
                      : () {
                          _handleLogin();
                        },
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
                          'Masuk Sekarang',
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
                        'Belum punya akun? ',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.grey[600],
                        ),
                      ),
                      BounceTapper(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterPage(),
                            ),
                          );
                        },
                        child: Text(
                          'Daftar Disini',
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
      ),
    );
  }
}
