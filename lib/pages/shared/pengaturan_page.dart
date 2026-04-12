import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_mobile/CONFIGURATION/CONFIGURATION.dart';
import 'package:pos_mobile/COMPONENTS/Components.dart';
import 'package:tabler_icons/tabler_icons.dart';
import 'package:pos_mobile/pages/owner/kelola_toko_page.dart';
import 'package:pos_mobile/pages/owner/manage_products_page.dart';
import 'package:pos_mobile/pages/owner/manage_categories_page.dart';
import 'package:pos_mobile/pages/owner/manage_stores_page.dart';
import 'package:bounce_tapper/bounce_tapper.dart';

class PengaturanPage extends StatefulWidget {
  const PengaturanPage({super.key});

  @override
  State<PengaturanPage> createState() => _PengaturanPageState();
}

class _PengaturanPageState extends State<PengaturanPage> {
  final TextEditingController _nameController = TextEditingController(
    text: 'Toko Berkah Jaya',
  );
  final TextEditingController _phoneController = TextEditingController(
    text: '081234567890',
  );
  final TextEditingController _emailController = TextEditingController(
    text: 'berkahjaya@example.com',
  );
  final TextEditingController _addressController = TextEditingController(
    text: 'Jl. Sudirman No. 123, Jakarta Selatan',
  );
  final TextEditingController _taxController = TextEditingController(
    text: '10',
  );
  final TextEditingController _serviceController = TextEditingController(
    text: '5',
  );

  String _openTime = '08:00';
  String _closeTime = '21:00';

  void _showComingSoon(BuildContext context, String feature) {
    MySnackBar(
      context: context,
      text: '$feature akan segera hadir!',
      status: ToastStatus.info,
    );
  }

  void _saveSettings() {
    MySnackBar(
      context: context,
      text: 'Pengaturan toko berhasil disimpan',
      status: ToastStatus.success,
    );
  }

  void _resetSettings() {
    setState(() {
      _nameController.text = 'Toko Berkah Jaya';
      _phoneController.text = '081234567890';
      _emailController.text = 'berkahjaya@example.com';
      _addressController.text = 'Jl. Sudirman No. 123, Jakarta Selatan';
      _taxController.text = '10';
      _serviceController.text = '5';
      _openTime = '08:00';
      _closeTime = '21:00';
    });
    MySnackBar(
      context: context,
      text: 'Perubahan dibatalkan',
      status: ToastStatus.info,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Warna.BG,
        body: Column(
          children: [
            // Tab Bar
            Container(
              color: Colors.white,
              child: TabBar(
                labelColor: Warna.Primary,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Warna.Primary,
                indicatorWeight: 3,
                labelStyle: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                tabs: const [
                  Tab(text: 'Kelola'),
                  Tab(text: 'Toko'),
                  Tab(text: 'Aplikasi'),
                ],
              ),
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                children: [
                  _buildKelolaTab(context),
                  _buildTokoTab(context),
                  _buildAplikasiTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKelolaTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // --- Core Data ---
        _buildSettingsItem(
          icon: TablerIcons.package,
          title: 'Kelola Produk',
          subtitle: 'Tambah, edit, dan hapus barang jualan Anda',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ManageProductsPage(),
              ),
            );
          },
        ),
        _buildSettingsItem(
          icon: TablerIcons.category,
          title: 'Kelola Kategori',
          subtitle: 'Atur pengelompokan produk agar lebih rapi',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const ManageCategoriesPage(currentCategories: []),
              ),
            );
          },
        ),
        _buildSettingsItem(
          icon: TablerIcons.building_store,
          title: 'Daftar Seluruh Toko',
          subtitle: 'Lihat dan kelola seluruh cabang toko Anda',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ManageStoresPage()),
            );
          },
        ),

        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Divider(),
        ),

        // --- People Management ---
        _buildSettingsItem(
          icon: TablerIcons.users,
          title: 'Kelola Karyawan / Kasir',
          subtitle: 'Atur hak akses dan daftar staf toko Anda',
          onTap: () => _showComingSoon(context, 'Kelola Karyawan'),
        ),
        _buildSettingsItem(
          icon: TablerIcons.heart,
          title: 'Kelola Pelanggan',
          subtitle: 'Daftar pelanggan setia dan program loyalitas',
          onTap: () => _showComingSoon(context, 'Kelola Pelanggan'),
        ),

        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Divider(),
        ),

        // --- Transaction & Hardware ---
        _buildSettingsItem(
          icon: TablerIcons.qrcode,
          title: 'Kelola QRIS',
          subtitle: 'Pengaturan pembayaran digital dan e-wallet',
          onTap: () => _showComingSoon(context, 'Kelola QRIS'),
        ),
        _buildSettingsItem(
          icon: TablerIcons.printer,
          title: 'Pengaturan Printer',
          subtitle: 'Sambungkan printer bluetooth untuk cetak struk',
          onTap: () => _showComingSoon(context, 'Pengaturan Printer'),
        ),
        _buildSettingsItem(
          icon: TablerIcons.receipt,
          title: 'Format Struk',
          subtitle: 'Sesuaikan tampilan dan teks pada struk belanja',
          onTap: () => _showComingSoon(context, 'Format Struk'),
        ),
      ],
    );
  }

  Widget _buildTokoTab(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo & Nama Toko Section
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      TablerIcons.building_store,
                      size: 40,
                      color: Warna.Primary,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: BounceTapper(
                      onTap: () => _showComingSoon(context, 'Ganti Logo'),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Warna.Primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          TablerIcons.camera,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            myTextField(
              controller: _nameController,
              labelText: 'Nama Toko',
              placeholder: 'Masukkan nama toko',
            ),
            const SizedBox(height: 16),

            myTextField(
              controller: _addressController,
              labelText: 'Alamat Lengkap',
              placeholder: 'Masukkan alamat toko',
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: myTextField(
                    controller: _phoneController,
                    labelText: 'No. Telepon',
                    placeholder: '08xx',
                    keyboardType: TextInputType.phone,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: myTextField(
                    controller: _emailController,
                    labelText: 'Email',
                    placeholder: 'email@toko.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: myTextField(
                    controller: _taxController,
                    labelText: 'Pajak (%)',
                    placeholder: '0',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: myTextField(
                    controller: _serviceController,
                    labelText: 'Layanan (%)',
                    placeholder: '0',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: mySelectTime(
                    labelText: 'Jam Buka',
                    selectedTime: _openTime,
                    onTap: () => _pickTime(context, true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: mySelectTime(
                    labelText: 'Jam Tutup',
                    selectedTime: _closeTime,
                    onTap: () => _pickTime(context, false),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: myButtonPrimary(
                    onPressed: _resetSettings,
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.black,
                    isOutlined: true,
                    child: Text(
                      'Batal',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: myButtonPrimary(
                    onPressed: _saveSettings,
                    backgroundColor: Warna.Primary,
                    foregroundColor: Colors.white,
                    child: Text(
                      'Simpan',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAplikasiTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _buildSettingsItem(
          icon: TablerIcons.crown,
          title: 'Upgrade ke Pro',
          subtitle: 'Nikmati fitur premium tanpa batas',
          iconColor: Colors.amber[700],
          onTap: () => _showComingSoon(context, 'Upgrade Pro'),
        ),
        const SizedBox(height: 8),
        _buildSettingsItem(
          icon: TablerIcons.question_circle,
          title: 'Pusat Bantuan',
          subtitle: 'Butuh bantuan? Hubungi tim support kami',
          onTap: () {},
        ),
        _buildSettingsItem(
          icon: TablerIcons.device_mobile,
          title: 'Tentang Aplikasi',
          subtitle: 'Informasi versi aplikasi dan informasi legal',
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _buildSettingsItem(
          icon: TablerIcons.logout,
          title: 'Log Out',
          subtitle: 'Keluar dari akun Anda secara aman',
          isDestructive: true,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDestructive
                ? Colors.red.withOpacity(0.1)
                : (iconColor != null
                      ? iconColor.withOpacity(0.1)
                      : Colors.grey[100]),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isDestructive ? Colors.red : (iconColor ?? Colors.grey[600]),
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: isDestructive ? Colors.red : Colors.black,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: isDestructive
                ? Colors.red.withOpacity(0.7)
                : Colors.grey[600],
          ),
        ),
        trailing: Icon(
          TablerIcons.chevron_right,
          color: isDestructive ? Colors.red.withOpacity(0.5) : Colors.grey[400],
          size: 18,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _pickTime(BuildContext context, bool isOpenTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Warna.Primary,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        final timeStr =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
        if (isOpenTime) {
          _openTime = timeStr;
        } else {
          _closeTime = timeStr;
        }
      });
    }
  }
}
