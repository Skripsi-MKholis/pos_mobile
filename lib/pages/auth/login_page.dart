import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_mobile/components/components.dart';
import 'package:pos_mobile/configuration/configuration.dart';
import 'package:pos_mobile/pages/auth/register_page.dart';
import 'package:tabler_icons/tabler_icons.dart';
import 'package:bounce_tapper/bounce_tapper.dart';

class LoginPage extends StatefulWidget {
  final Function(String role) onLoginSuccess;
  const LoginPage({super.key, required this.onLoginSuccess});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _selectedRole = 'Owner';

  final List<Map<String, dynamic>> _roles = [
    {
      'name': 'Owner',
      'icon': TablerIcons.crown,
      'description': 'Kelola Toko & Laporan',
    },
    {
      'name': 'Karyawan',
      'icon': TablerIcons.user_check,
      'description': 'Kasir & Transaksi',
    },
    {
      'name': 'Pelanggan',
      'icon': TablerIcons.users,
      'description': 'Pesan Produk',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Warna.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              const SizedBox(height: 32),

              // UI Role Selection for testing
              Text(
                'Pilih Role (Untuk Uji Coba)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: _roles.map((role) {
                  bool isSelected = _selectedRole == role['name'];
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: BounceTapper(
                        onTap: () {
                          setState(() {
                            _selectedRole = role['name'];
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? Warna.primary : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? Warna.primary
                                  : Colors.grey.shade200,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Warna.primary.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Column(
                            children: [
                              Icon(
                                role['icon'],
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey[600],
                                size: 20,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                role['name'],
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              myTextField(
                controller: _emailController,
                placeholder: 'Email atau Username',
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
                onPressed: () {
                  // Simulate Login logic
                  /*  if (_emailController.text.isEmpty ||
                      _passwordController.text.isEmpty) {
                    mySnackBar(
                      context: context,
                      text: 'Terdapat input kosong!',
                      status: ToastStatus.warning,
                    );
                    return;
                  } */

                  // For trial purpose, just pass the selected role
                  widget.onLoginSuccess(_selectedRole);
                },
                backgroundColor: Warna.primary,
                foregroundColor: Colors.white,
                child: Text(
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
    );
  }
}
