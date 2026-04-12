import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pos_mobile/CONFIGURATION/CONFIGURATION.dart';
import 'package:pos_mobile/COMPONENTS/Components.dart';
import 'package:pos_mobile/pages/owner/apply_discount_page.dart';
import 'package:tabler_icons/tabler_icons.dart';

class ManageDiscountsPage extends StatefulWidget {
  const ManageDiscountsPage({super.key});

  @override
  State<ManageDiscountsPage> createState() => _ManageDiscountsPageState();
}

class _ManageDiscountsPageState extends State<ManageDiscountsPage> {
  // Mock data for discounts
  List<Map<String, dynamic>> discounts = [
    {
      'name': 'Promo Awal Tahun',
      'type': 'Persentase (%)',
      'value': 10,
      'isActive': true,
    },
    {
      'name': 'Diskon Member',
      'type': 'Nominal (Rp)',
      'value': 5000,
      'isActive': true,
    },
    {
      'name': 'Flash Sale',
      'type': 'Persentase (%)',
      'value': 25,
      'isActive': false,
    },
  ];

  void _showDiscountForm({Map<String, dynamic>? discount, int? index}) {
    final nameController = TextEditingController(text: discount?['name'] ?? '');
    final valueController = TextEditingController(
      text: discount?['value']?.toString() ?? '',
    );
    String type = discount?['type'] ?? 'Persentase (%)';
    bool isActive = discount?['isActive'] ?? true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 20,
                left: 20,
                right: 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      discount == null ? 'Tambah Diskon' : 'Edit Diskon',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                
                    myTextField(
                      controller: nameController,
                      labelText: 'Nama Diskon',
                      placeholder: 'Contoh: Diskon Karyawan',
                    ),
                    const SizedBox(height: 16),
                
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: mySelectField(
                            labelText: 'Tipe',
                            selectedValue: type,
                            items: ['Persentase (%)', 'Nominal (Rp)'],
                            onChanged: (val) {
                              if (val != null) {
                                setModalState(() => type = val);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: myTextField(
                            controller: valueController,
                            labelText: 'Nilai',
                            placeholder: type == 'Persentase (%)' ? '10' : '5000',
                            keyboardType: TextInputType.number,
                            prefix: type == 'Nominal (Rp)' ? const Text('Rp ') : null,
                            suffix: type == 'Persentase (%)' ? const Text('%') : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Status Diskon',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              isActive ? 'Aktif' : 'Non-aktif',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: isActive ? Colors.green : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: isActive,
                          onChanged: (val) {
                            setModalState(() => isActive = val);
                          },
                          activeColor: Warna.Primary,
                        ),
                      ],
                    ),
                
                    const SizedBox(height: 32),
                    myButtonPrimary(
                      onPressed: () {
                        if (nameController.text.isEmpty || valueController.text.isEmpty) {
                          MySnackBar(
                            context: context,
                            text: 'Harap isi semua bidang!',
                            status: ToastStatus.error,
                          );
                          return;
                        }
                
                        final newValue = double.tryParse(valueController.text) ?? 0;
                
                        setState(() {
                          final data = {
                            'name': nameController.text,
                            'type': type,
                            'value': newValue,
                            'isActive': isActive,
                          };
                
                          if (index == null) {
                            discounts.add(data);
                          } else {
                            discounts[index] = data;
                          }
                        });
                
                        Navigator.pop(context);
                        MySnackBar(
                          context: context,
                          text: 'Diskon berhasil disimpan',
                          status: ToastStatus.success,
                        );
                      },
                      backgroundColor: Warna.Primary,
                      foregroundColor: Colors.white,
                      child: const Text(
                        'Simpan',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Hapus Diskon?',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus diskon "${discounts[index]['name']}"?',
          style: GoogleFonts.plusJakartaSans(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: TextStyle(color: Colors.grey[600])),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                discounts.removeAt(index);
              });
              Navigator.pop(context);
              MySnackBar(
                context: context,
                text: 'Diskon berhasil dihapus',
                status: ToastStatus.success,
              );
            },
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: Warna.BG,
      appBar: MyAppBar(
        title: 'Kelola Diskon',
        isCenter: true,
      ),
      body: discounts.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: discounts.length,
              itemBuilder: (context, index) {
                final d = discounts[index];
                final bool isActive = d['isActive'] ?? false;
                final String valueDisplay = d['type'] == 'Persentase (%)'
                    ? '${d['value']}%'
                    : currencyFormat.format(d['value']);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isActive
                              ? Warna.Primary.withValues(alpha: 0.1)
                              : Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          TablerIcons.discount_2,
                          color: isActive ? Warna.Primary : Colors.grey,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              d['name'],
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isActive ? Colors.black : Colors.grey,
                              ),
                            ),
                            Text(
                              valueDisplay,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                color: isActive ? Warna.Primary : Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              TablerIcons.square_check,
                              color: Colors.green,
                              size: 20,
                            ),
                            tooltip: 'Terapkan ke Produk',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ApplyDiscountPage(
                                    selectedDiscount: d,
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              TablerIcons.edit,
                              color: Colors.blue,
                              size: 20,
                            ),
                            onPressed: () => _showDiscountForm(
                              discount: d,
                              index: index,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              TablerIcons.trash,
                              color: Colors.red,
                              size: 20,
                            ),
                            onPressed: () => _confirmDelete(index),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDiscountForm(),
        backgroundColor: Warna.Primary,
        child: const Icon(TablerIcons.plus, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(TablerIcons.discount, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Belum ada diskon',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan diskon untuk menarik pelanggan',
            style: GoogleFonts.plusJakartaSans(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
