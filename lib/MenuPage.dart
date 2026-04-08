import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_mobile/CONFIGURATION/CONFIGURATION.dart';
import 'package:pos_mobile/COMPONENTS/Components.dart';
import 'package:tabler_icons/tabler_icons.dart';
import 'package:bounce_tapper/bounce_tapper.dart';
import 'package:pos_mobile/KasirPage.dart';
import 'package:pos_mobile/DashboardPage.dart';
import 'package:pos_mobile/RiwayatTransaksiPage.dart';
import 'package:pos_mobile/LaporanPage.dart';
import 'package:pos_mobile/PengaturanPage.dart';
import 'package:marquee/marquee.dart';
import 'package:pos_mobile/KelolaTokoPage.dart';
import 'package:pos_mobile/ManageProductsPage.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Warna.BG,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Menu Utama',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pilih fitur yang ingin Anda gunakan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildStoreCard(),
              const SizedBox(height: 32),

              // Features Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.2,
                children: [
                  _buildFeatureCard(
                    title: 'Kasir (POS)',
                    subtitle: 'Transaksi Penjualan',
                    icon: Icons.point_of_sale_rounded,
                    color: Warna.Primary,
                    onTap: () {
                      _navigateTo(context, const KasirPage());
                    },
                  ),
                  _buildFeatureCard(
                    title: 'Dashboard',
                    subtitle: 'Statistik & Ringkasan',
                    icon: Icons.dashboard_rounded,
                    color: Colors.blue[400]!,
                    onTap: () {
                      _navigateTo(context, const DashboardPage());
                    },
                  ),
                  _buildFeatureCard(
                    title: 'Riwayat',
                    subtitle: 'Data Transaksi',
                    icon: Icons.history_rounded,
                    color: Colors.orange[400]!,
                    onTap: () {
                      _navigateTo(context, const RiwayatTransaksiPage());
                    },
                  ),
                  _buildFeatureCard(
                    title: 'Laporan',
                    subtitle: 'Laporan Penjualan',
                    icon: Icons.bar_chart_rounded,
                    color: Colors.purple[400]!,
                    onTap: () {
                      _navigateTo(context, const LaporanPage());
                    },
                  ),
                  _buildFeatureCard(
                    title: 'Produk',
                    subtitle: 'Kelola Stok & Barang',
                    icon: Icons.inventory_2_rounded,
                    color: Colors.green[400]!,
                    onTap: () {
                      _navigateTo(context, const ManageProductsPage());
                    },
                  ),
                  _buildFeatureCard(
                    title: 'Pelanggan',
                    subtitle: 'Data Member',
                    icon: Icons.people_alt_rounded,
                    color: Colors.pink[400]!,
                    onTap: () {
                      MySnackBar(
                        context: context,
                        text: 'Fitur Manajemen Pelanggan segera hadir',
                        status: ToastStatus.info,
                      );
                    },
                  ),
                  _buildFeatureCard(
                    title: 'Pengaturan',
                    subtitle: 'Konfigurasi Aplikasi',
                    icon: Icons.settings_rounded,
                    color: Colors.blueGrey[400]!,
                    onTap: () {
                      _navigateTo(context, const PengaturanPage());
                    },
                  ),
                  _buildFeatureCard(
                    title: 'Profil',
                    subtitle: 'Info Akun',
                    icon: Icons.person_rounded,
                    color: Colors.teal[400]!,
                    onTap: () {
                      MySnackBar(
                        context: context,
                        text: 'Menuju Profil Admin',
                        status: ToastStatus.info,
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // App Info Card (Optional)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Warna.Primary, Warna.Secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Warna.Primary.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Informasi Sistem',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Sistem POS Mobile v1.0.0 Aktif',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12,
                            ),
                          ),
                        ],
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

  Widget _buildStoreCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Warna.Primary,
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Warna.Primary, Warna.Primary.withOpacity(0.8)],
        ),
        boxShadow: [
          BoxShadow(
            color: Warna.Primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                // Store Logo/Avatar
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      TablerIcons.building_store,
                      color: Warna.Primary,
                      size: 30,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Store Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Toko Berkah Jaya',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Premium',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Jl. Sudirman No. 123, Jakarta',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(
                            Icons.circle,
                            color: Colors.greenAccent,
                            size: 10,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Buka',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            TablerIcons.clock,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              '08:00 - 21:00',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Edit Button
                IconButton(
                  onPressed: () {
                    _navigateTo(context, const KelolaTokoPage());
                  },
                  icon: const Icon(
                    TablerIcons.chevron_right,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return BounceTapper(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Icon Container
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              // Text Content
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    SizedBox(
                      height: 14,
                      child: Marquee(
                        text: subtitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                        scrollAxis: Axis.horizontal,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        blankSpace: 10.0,
                        velocity: 25.0,
                        pauseAfterRound: const Duration(seconds: 1),
                        accelerationDuration: const Duration(seconds: 1),
                        accelerationCurve: Curves.linear,
                        decelerationDuration: const Duration(milliseconds: 500),
                        decelerationCurve: Curves.easeOut,
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
