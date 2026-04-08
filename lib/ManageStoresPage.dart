import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_mobile/CONFIGURATION/CONFIGURATION.dart';
import 'package:pos_mobile/COMPONENTS/Components.dart';
import 'package:tabler_icons/tabler_icons.dart';
import 'package:bounce_tapper/bounce_tapper.dart';
import 'package:pos_mobile/KelolaTokoPage.dart';

class ManageStoresPage extends StatefulWidget {
  const ManageStoresPage({super.key});

  @override
  State<ManageStoresPage> createState() => _ManageStoresPageState();
}

class _ManageStoresPageState extends State<ManageStoresPage> {
  final List<Map<String, String>> _stores = [
    {
      'name': 'Toko Berkah Jaya',
      'email': 'admin@pos.com',
      'address': 'Jl. Sudirman No. 123, Jakarta',
      'status': 'active',
    },
    {
      'name': 'Cabang Sudirman',
      'email': 'sudirman@pos.com',
      'address': 'Jl. Jenderal Sudirman No. 45, Jakarta',
      'status': 'inactive',
    },
    {
      'name': 'Cabang Thamrin',
      'email': 'thamrin@pos.com',
      'address': 'Kawasan M.H. Thamrin Kav. 10, Jakarta',
      'status': 'inactive',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Warna.BG,
      appBar: MyAppBar(
        title: 'Kelola Seluruh Toko',
        isCenter: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _stores.length,
        itemBuilder: (context, index) {
          final store = _stores[index];
          final isActive = store['status'] == 'active';

          return _buildStoreCard(store, isActive, index);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const KelolaTokoPage()),
          );
        },
        backgroundColor: Warna.Primary,
        icon: const Icon(TablerIcons.plus, color: Colors.white),
        label: Text(
          'Tambah Toko',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStoreCard(Map<String, String> store, bool isActive, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Warna.Primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    TablerIcons.building_store,
                    color: Warna.Primary,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              store['name']!,
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8FAF0),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Aktif',
                                style: GoogleFonts.plusJakartaSans(
                                  color: const Color(0xff1AC966),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        store['email']!,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            TablerIcons.map_pin,
                            size: 14,
                            color: Colors.black38,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              store['address']!,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: Colors.black38,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(color: Colors.grey[100], height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const KelolaTokoPage(),
                        ),
                      );
                    },
                    icon: const Icon(TablerIcons.edit, size: 18),
                    label: const Text('Kelola'),
                    style: TextButton.styleFrom(
                      foregroundColor: Warna.Primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() {
                        for (var s in _stores) {
                          s['status'] = 'inactive';
                        }
                        _stores[index]['status'] = 'active';
                      });
                      MySnackBar(
                        context: context,
                        text: 'Toko ${store['name']} terpilih',
                        status: ToastStatus.success,
                      );
                    },
                    icon: Icon(
                      isActive ? TablerIcons.circle_check : TablerIcons.circle,
                      size: 18,
                    ),
                    label: Text(isActive ? 'Aktif' : 'Pilih'),
                    style: TextButton.styleFrom(
                      foregroundColor: isActive ? const Color(0xff1AC966) : Colors.black54,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                BounceTapper(
                  onTap: () => _showDeleteDialog(store['name']!, index),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      TablerIcons.trash,
                      size: 18,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(String name, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Hapus Toko',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus "$name"? Tindakan ini tidak dapat dibatalkan.',
          style: GoogleFonts.plusJakartaSans(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: GoogleFonts.plusJakartaSans(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _stores.removeAt(index);
              });
              Navigator.pop(context);
              MySnackBar(
                context: context,
                text: 'Toko berhasil dihapus',
                status: ToastStatus.error,
              );
            },
            child: Text(
              'Hapus',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
