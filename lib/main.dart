import 'package:flutter/material.dart';
import 'package:pos_mobile/pages/auth/login_page.dart';
import 'package:pos_mobile/pages/auth/store_selection_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_mobile/pages/owner/manage_stores_page.dart';
import 'package:pos_mobile/pages/shared/menu_page.dart';
import 'package:pos_mobile/pages/karyawan/kasir_page.dart';
import 'package:pos_mobile/pages/owner/laporan_page.dart';
import 'package:pos_mobile/pages/shared/pengaturan_page.dart';
import 'package:pos_mobile/pages/karyawan/riwayat_transaksi_page.dart';
import 'package:pos_mobile/pages/pelanggan/beranda_pelanggan_page.dart';
import 'package:pos_mobile/components/components.dart';
import 'package:pos_mobile/configuration/configuration.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:tabler_icons/tabler_icons.dart';
import 'package:provider/provider.dart';
import 'package:pos_mobile/repositories/transaction_repository.dart';
import 'package:pos_mobile/repositories/product_repository.dart';
import 'package:pos_mobile/repositories/report_repository.dart';
import 'package:pos_mobile/repositories/master_repository.dart';
import 'package:pos_mobile/services/sync_service.dart';
import 'package:pos_mobile/repositories/customer_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pos_mobile/providers/auth_provider.dart';
import 'package:pos_mobile/repositories/store_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://nolawradcdkemdyumoqs.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5vbGF3cmFkY2RrZW1keXVtb3FzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU5MjAzNjIsImV4cCI6MjA5MTQ5NjM2Mn0.uwTp2g6yPJv6JUvyv4NBr1m0DgVt5fmKPiR3ED4hs4I',
  );

  // Initialize background sync
  SyncService().initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        Provider(create: (_) => TransactionRepository()),
        Provider(create: (_) => ProductRepository()),
        Provider(create: (_) => MasterRepository()),
        Provider(create: (_) => ReportRepository()),
        Provider(create: (_) => StoreRepository()),
        Provider(create: (_) => CustomerRepository()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (authProvider.isLoading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Warna.primary),
          useMaterial3: true,
        ),
        home: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    Widget homeWidget;
    if (!authProvider.isAuthenticated) {
      homeWidget = const LoginPage();
    } else if (authProvider.activeMembership == null) {
      homeWidget = const StoreSelectionPage();
    } else {
      homeWidget = const MainScreen();
    }

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
      home: homeWidget,
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

  List<Map<String, dynamic>> _getNavItems(String role) {
    if (role == 'Owner') {
      return [
        {
          'icon': Icons.grid_view_rounded,
          'text': 'Menu',
          'page': MenuPage(role: role),
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
    } else if (role == 'Karyawan') {
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
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final selectedStore = authProvider.selectedStore;
    final activeMembership = authProvider.activeMembership;
    final role = activeMembership?.role ?? 'Pelanggan';
    final navItems = _getNavItems(role);

    return Scaffold(
      appBar: MyAppBar(
        title: selectedStore?.name ?? 'POS Mobile',
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
              onSelected: (value) async {
                switch (value) {
                  case 'profile':
                    // Navigate to profile page
                    break;
                  case 'logout':
                    await authProvider.logout();
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            selectedStore?.name ?? 'Pilih Toko',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            user?.email ?? '',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                            overflow: TextOverflow.ellipsis,
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
                    ...navItems.asMap().entries.map((entry) {
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

                    if (role == 'Owner') ...[
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
                      icon: TablerIcons.switch_horizontal,
                      text: 'Pindah Toko',
                      onTap: () {
                        Navigator.pop(context);
                        authProvider.selectMembership(null); // Resetting back to selection
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
                  onTap: () async {
                    Navigator.pop(context);
                    await authProvider.logout();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: navItems[_selectedIndex]['page'],

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
              tabs: navItems.map((item) {
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
