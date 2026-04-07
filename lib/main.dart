import 'package:flutter/material.dart';
import 'package:pos_mobile/COMPONENTS/Components.dart';
import 'package:pos_mobile/KasirPage.dart';
import 'package:pos_mobile/CheckoutPage.dart';
import 'package:pos_mobile/LaporanPage.dart';
import 'package:pos_mobile/PengaturanPage.dart';
import 'package:pos_mobile/DashboardPage.dart';
import 'package:pos_mobile/RiwayatTransaksiPage.dart';
import 'package:pos_mobile/CONFIGURATION/CONFIGURATION.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'POS Mobile',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Warna.Primary,
          primary: Warna.Primary,
        ),
        scaffoldBackgroundColor: Warna.BG,
        textTheme: GoogleFonts.plusJakartaSansTextTheme(),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    DashboardPage(),
    KasirPage(),
    RiwayatTransaksiPage(),
    PengaturanPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    bool isSelected = false,
    Color? iconColor,
    Color? textColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: isSelected
            ? colorScheme.primary.withOpacity(0.1)
            : Colors.transparent,
        leading: Icon(
          icon,
          color:
              iconColor ?? (isSelected ? colorScheme.primary : Colors.black54),
          size: 22,
        ),
        title: Text(
          text,
          style: TextStyle(
            color:
                textColor ??
                (isSelected ? colorScheme.primary : Colors.black87),
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        onTap: onTap,
        dense: true,
        horizontalTitleGap: 0,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /* appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('POS Mobile'),
      ), */
      appBar: MyAppBar(
        title: 'POS Mobile',
        isCenter: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: PopupMenuButton(
              offset: const Offset(0, 45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'profile', child: Text('Profile')),
                const PopupMenuItem(value: 'logout', child: Text('Logout')),
              ],
              child: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: const Icon(Icons.person, size: 20),
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header Drawer
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      child: Icon(
                        Icons.person,
                        color: Theme.of(context).colorScheme.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Admin Kasir',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            'admin@pos.com',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Divider(color: Colors.grey[200], height: 1),
              const SizedBox(height: 8),

              // Menu Items
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    _buildDrawerItem(
                      icon: Icons.dashboard_outlined,
                      text: 'Dashboard',
                      isSelected: _selectedIndex == 0,
                      onTap: () {
                        Navigator.pop(context);
                        _onItemTapped(0);
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.point_of_sale,
                      text: 'Kasir',
                      isSelected: _selectedIndex == 1,
                      onTap: () {
                        Navigator.pop(context);
                        _onItemTapped(1);
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.shopping_cart_outlined,
                      text: 'Checkout',
                      isSelected: _selectedIndex == 2,
                      onTap: () {
                        Navigator.pop(context);
                        _onItemTapped(2);
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.history,
                      text: 'Riwayat Transaksi',
                      isSelected: _selectedIndex == 3,
                      onTap: () {
                        Navigator.pop(context);
                        _onItemTapped(3);
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.list_alt,
                      text: 'Laporan',
                      isSelected: _selectedIndex == 4,
                      onTap: () {
                        Navigator.pop(context);
                        _onItemTapped(4);
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.settings_outlined,
                      text: 'Pengaturan',
                      isSelected: _selectedIndex == 5,
                      onTap: () {
                        Navigator.pop(context);
                        _onItemTapped(5);
                      },
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      child: Divider(color: Colors.grey[200], height: 1),
                    ),

                    const Padding(
                      padding: EdgeInsets.only(left: 16, top: 4, bottom: 8),
                      child: Text(
                        'Lainnya',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    _buildDrawerItem(
                      icon: Icons.person_outline,
                      text: 'Profil',
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.help_outline,
                      text: 'Bantuan & Dukungan',
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.info_outline,
                      text: 'Tentang Aplikasi',
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),

              // Logout Button
              Divider(color: Colors.grey[200], height: 1),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: _buildDrawerItem(
                  icon: Icons.logout,
                  text: 'Keluar',
                  iconColor: Colors.red[400],
                  textColor: Colors.red[400],
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: _pages[_selectedIndex],

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(.1)),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              rippleColor: Colors.grey[300]!,
              hoverColor: Colors.grey[100]!,
              gap: 8,
              activeColor: Theme.of(context).colorScheme.primary,
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withOpacity(0.1),
              color: Colors.grey[500],
              tabs: const [
                GButton(icon: Icons.dashboard, text: 'Dashboard'),
                GButton(icon: Icons.point_of_sale, text: 'Kasir'),
                GButton(icon: Icons.history, text: 'Riwayat'),
                GButton(icon: Icons.settings, text: 'Pengaturan'),
              ],
              selectedIndex: _selectedIndex,
              onTabChange: _onItemTapped,
            ),
          ),
        ),
      ),
    );
  }
}
