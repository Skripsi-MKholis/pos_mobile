import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_mobile/COMPONENTS/Components.dart';
import 'package:pos_mobile/CONFIGURATION/CONFIGURATION.dart';
import 'package:tabler_icons/tabler_icons.dart';
import 'package:bounce_tapper/bounce_tapper.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Warna.BG,
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
                'Lengkapi data di bawah untuk mendaftar',
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

              myButtonPrimary(
                onPressed: () {
                  if (_nameController.text.isEmpty ||
                      _emailController.text.isEmpty ||
                      _passwordController.text.isEmpty) {
                    MySnackBar(
                      context: context,
                      text: 'Terdapat input kosong!',
                      status: ToastStatus.warning,
                    );
                    return;
                  }
                  
                  if (_passwordController.text != _confirmPasswordController.text) {
                    MySnackBar(
                      context: context,
                      text: 'Password tidak cocok!',
                      status: ToastStatus.error,
                    );
                    return;
                  }

                  MySnackBar(
                    context: context,
                    text: 'Pendaftaran berhasil! Silakan login.',
                    status: ToastStatus.success,
                  );
                  Navigator.pop(context);
                },
                backgroundColor: Warna.Primary,
                foregroundColor: Colors.white,
                child: Text(
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
                      'Suda punya akun? ',
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
                          color: Warna.Primary,
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
