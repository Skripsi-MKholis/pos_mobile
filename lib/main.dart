import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:pos_mobile/components/components.dart';
import 'package:pos_mobile/pages/auth/login_page.dart';
import 'package:pos_mobile/pages/karyawan/kasir_page.dart';
import 'package:pos_mobile/pages/owner/laporan_page.dart';
import 'package:pos_mobile/pages/shared/pengaturan_page.dart';
import 'package:pos_mobile/pages/karyawan/riwayat_transaksi_page.dart';
import 'package:pos_mobile/configuration/configuration.dart';
import 'package:pos_mobile/pages/shared/menu_page.dart';
import 'package:pos_mobile/pages/pelanggan/beranda_pelanggan_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:pos_mobile/pages/owner/kelola_toko_page.dart';
import 'package:pos_mobile/pages/owner/manage_stores_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _userRole;

  void _login(String role) {
    setState(() {
      _userRole = role;
    });
  }

  void _logout() {
    setState(() {
      _userRole = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'POS Mobile',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Warna.primary,
          primary: Warna.primary,
        ),
        scaffoldBackgroundColor: Warna.bg,
        textTheme: GoogleFonts.plusJakartaSansTextTheme(),
        useMaterial3: true,
      ),
      home: _userRole == null
          ? LoginPage(onLoginSuccess: _login)
          : MainScreen(role: _userRole!, onLogout: _logout),
    );
  }
}

class MainScreen extends StatefulWidget {
  final String role;
  final VoidCallback onLogout;
  const MainScreen({super.key, required this.role, required this.onLogout});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Map<String, String>> _stores = [
    {'name': 'Toko Berkah Jaya', 'email': 'admin@pos.com'},
    {'name': 'Cabang Sudirman', 'email': 'sudirman@pos.com'},
  ];
  late Map<String, String> _selectedStore;

  @override
  void initState() {
    super.initState();
    _selectedStore = _stores[0];
  }

  List<Map<String, dynamic>> _getNavItems() {
    if (widget.role == 'Owner') {
      return [
        {
          'icon': Icons.grid_view_rounded,
          'text': 'Menu',
          'page': MenuPage(role: widget.role),
        },
        {
          'icon': Icons.point_of_sale,
          'text': 'Kasir',
          'page': const KasirPage(),
        },
        {
          'icon': Icons.bar_chart_rounded,
          'text': 'Laporan',
          'page': const LaporanPage(),
        },
        {
          'icon': Icons.settings,
          'text': 'Setelan',
          'page': const PengaturanPage(),
        },
      ];
    } else if (widget.role == 'Karyawan') {
      return [
        {
          'icon': Icons.point_of_sale,
          'text': 'Kasir',
          'page': const KasirPage(),
        },
        {
          'icon': Icons.history,
          'text': 'Riwayat',
          'page': const RiwayatTransaksiPage(),
        },
        {
          'icon': Icons.settings,
          'text': 'Setelan',
          'page': const PengaturanPage(),
        },
      ];
    } else {
      // Pelanggan
      return [
        {
          'icon': Icons.home_rounded,
          'text': 'Beranda',
          'page': const BerandaPelangganPage(),
        },
        {
          'icon': Icons.history,
          'text': 'Pesanan',
          'page': const RiwayatTransaksiPage(),
        },
        {
          'icon': Icons.person,
          'text': 'Profil',
          'page': const PengaturanPage(),
        },
      ];
    }
  }

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
            ? colorScheme.primary.withValues(alpha: 0.1)
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
            child: PopupMenuButton<String>(
              offset: const Offset(0, 45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.white,
              surfaceTintColor: Colors.white,
              child: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: const Icon(Icons.person, size: 20),
              ),
              onSelected: (value) {
                switch (value) {
                  case 'profile':
                    // Navigate to profile page
                    break;
                  case 'logout':
                    widget.onLogout();
                    break;
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'profile',
                  child: Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 20,
                        color: Colors.black54,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Profile',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, size: 20, color: Colors.red[400]),
                      const SizedBox(width: 12),
                      Text(
                        'Logout',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
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
                      ).colorScheme.primary.withValues(alpha: 0.1),
                      child: Icon(
                        Icons.store_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton2<Map<String, String>?>(
                          isExpanded: true,
                          customButton: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _selectedStore['name']!,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    size: 20,
                                    color: Colors.black45,
                                  ),
                                ],
                              ),
                              Text(
                                _selectedStore['email']!,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                          items: [
                            ..._stores.map(
                              (store) => DropdownItem<Map<String, String>?>(
                                value: store,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.storefront_outlined,
                                      size: 18,
                                      color: store == _selectedStore
                                          ? Theme.of(
                                              context,
                                            ).colorScheme.primary
                                          : Colors.black54,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      store['name']!,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: store == _selectedStore
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                        color: store == _selectedStore
                                            ? Theme.of(
                                                context,
                                              ).colorScheme.primary
                                            : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const DropdownItem<Map<String, String>?>(
                              enabled: false,
                              value: null,
                              child: Divider(height: 1),
                            ),
                            DropdownItem<Map<String, String>?>(
                              value: const {'name': 'ADD_NEW', 'email': ''},
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.add_circle_outline_rounded,
                                    size: 18,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Tambah Toko',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DropdownItem<Map<String, String>?>(
                              value: const {'name': 'MANAGE_ALL', 'email': ''},
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.settings_suggest_outlined,
                                    size: 18,
                                    color: Colors.black54,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Kelola Semua Toko',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            final action = value['name'];
                            if (action == 'ADD_NEW') {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const KelolaTokoPage(),
                                ),
                              );
                            } else if (action == 'MANAGE_ALL') {
                              Navigator.pop(context);
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ManageStoresPage(),
                                ),
                              );
                            } else {
                              setState(() {
                                _selectedStore = value;
                              });
                            }
                          },
                          dropdownStyleData: DropdownStyleData(
                            width: 250,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            offset: const Offset(-8, -5),
                          ),
                          menuItemStyleData: const MenuItemStyleData(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                          ),
                        ),
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
                    ..._getNavItems().asMap().entries.map((entry) {
                      int idx = entry.key;
                      var item = entry.value;
                      return _buildDrawerItem(
                        icon: item['icon'],
                        text: item['text'],
                        isSelected: _selectedIndex == idx,
                        onTap: () {
                          Navigator.pop(context);
                          _onItemTapped(idx);
                        },
                      );
                    }),

                    if (widget.role == 'Owner') ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        child: Divider(color: Colors.grey[200], height: 1),
                      ),
                      _buildDrawerItem(
                        icon: Icons.store_mall_directory_outlined,
                        text: 'Kelola Seluruh Toko',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ManageStoresPage(),
                            ),
                          );
                        },
                      ),
                    ],

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
                    widget.onLogout();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: _getNavItems()[_selectedIndex]['page'],

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(blurRadius: 20, color: Colors.black.withValues(alpha: .1)),
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
              ).colorScheme.primary.withValues(alpha: 0.1),
              color: Colors.grey[500],
              tabs: _getNavItems().map((item) {
                return GButton(icon: item['icon'], text: item['text']);
              }).toList(),
              selectedIndex: _selectedIndex,
              onTabChange: _onItemTapped,
            ),
          ),
        ),
      ),
    );
  }
}
