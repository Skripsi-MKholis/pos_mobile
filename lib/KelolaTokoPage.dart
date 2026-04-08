import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_mobile/CONFIGURATION/CONFIGURATION.dart';
import 'package:pos_mobile/COMPONENTS/Components.dart';
import 'package:tabler_icons/tabler_icons.dart';
import 'package:bounce_tapper/bounce_tapper.dart';

class KelolaTokoPage extends StatefulWidget {
  const KelolaTokoPage({super.key});

  @override
  State<KelolaTokoPage> createState() => _KelolaTokoPageState();
}

class _KelolaTokoPageState extends State<KelolaTokoPage> {
  final TextEditingController _nameController =
      TextEditingController(text: 'Toko Berkah Jaya');
  final TextEditingController _phoneController =
      TextEditingController(text: '081234567890');
  final TextEditingController _emailController =
      TextEditingController(text: 'berkahjaya@example.com');
  final TextEditingController _addressController = TextEditingController(
    text: 'Jl. Sudirman No. 123, Jakarta Selatan, DKI Jakarta 12190',
  );
  final TextEditingController _taxController = TextEditingController(text: '10');
  final TextEditingController _serviceController =
      TextEditingController(text: '5');
  final TextEditingController _footerController = TextEditingController(
    text: 'Terima kasih telah berbelanja!',
  );

  String? _selectedCategory = 'Restoran/Cafe';
  final List<String> _categories = [
    'Restoran/Cafe',
    'Retail/Toko',
    'Jasa/Laundry',
    'Bengkel',
    'Lainnya',
  ];

  bool _isStoreOpen = true;
  String _openTime = '08:00';
  String _closeTime = '21:00';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Warna.BG,
      appBar: MyAppBar(
        title: 'Kelola Toko',
        isCenter: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLogoSection(),
            const SizedBox(height: 32),
            _buildSectionHeader('Informasi Dasar'),
            const SizedBox(height: 12),
            myTextField(
              controller: _nameController,
              labelText: 'Nama Toko',
              placeholder: 'Masukkan nama toko',
            ),
            const SizedBox(height: 16),
            mySelectField(
              labelText: 'Kategori Bisnis',
              selectedValue: _selectedCategory,
              items: _categories,
              onChanged: (val) => setState(() => _selectedCategory = val),
            ),
            const SizedBox(height: 32),
            _buildSectionHeader('Kontak & Alamat'),
            const SizedBox(height: 12),
            myTextField(
              controller: _phoneController,
              labelText: 'No. Telepon',
              placeholder: 'Masukkan nomor telepon',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            myTextField(
              controller: _emailController,
              labelText: 'Email',
              placeholder: 'Masukkan email',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            myTextField(
              controller: _addressController,
              labelText: 'Alamat Lengkap',
              placeholder: 'Masukkan alamat lengkap',
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            _buildSectionHeader('Operasional'),
            const SizedBox(height: 12),
            _buildStoreStatusToggle(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: mySelectTime(
                    labelText: 'Jam Buka',
                    selectedTime: _openTime,
                    onTap: () => _pickTime(true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: mySelectTime(
                    labelText: 'Jam Tutup',
                    selectedTime: _closeTime,
                    onTap: () => _pickTime(false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildSectionHeader('Pengaturan Struk'),
            const SizedBox(height: 12),
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
                const SizedBox(width: 16),
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
            myTextField(
              controller: _footerController,
              labelText: 'Pesan Kaki Struk (Footer)',
              placeholder: 'Contoh: Terima kasih!',
            ),
            const SizedBox(height: 40),
            myButtonPrimary(
              onPressed: () {
                MySnackBar(
                  context: context,
                  text: 'Perubahan berhasil disimpan',
                  status: ToastStatus.success,
                );
                Navigator.pop(context);
              },
              backgroundColor: Warna.Primary,
              foregroundColor: Colors.white,
              child: Text(
                'Simpan Perubahan',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Warna.Primary,
      ),
    );
  }

  Widget _buildLogoSection() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              TablerIcons.building_store,
              size: 50,
              color: Warna.Primary,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: BounceTapper(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Warna.Primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  TablerIcons.camera,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreStatusToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            _isStoreOpen ? TablerIcons.circle_check : TablerIcons.circle_x,
            color: _isStoreOpen ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status Toko',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  _isStoreOpen ? 'Sedang Buka' : 'Sedang Tutup',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isStoreOpen,
            onChanged: (val) => setState(() => _isStoreOpen = val),
            activeColor: Warna.Primary,
          ),
        ],
      ),
    );
  }

  Future<void> _pickTime(bool isOpenTime) async {
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
