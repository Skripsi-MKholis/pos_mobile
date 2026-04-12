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
  bool _isGridView = false;
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
                              isActive ? 'Aktif - Promo ini akan muncul di pembayaran' : 'Non-aktif - Promo ini disembunyikan',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
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
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
            icon: Icon(
              _isGridView ? TablerIcons.list : TablerIcons.layout_grid,
              color: Warna.Primary,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: discounts.isEmpty
          ? _buildEmptyState()
          : _isGridView
              ? GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: discounts.length,
                  itemBuilder: (context, index) {
                    final d = discounts[index];
                    final bool isActive = d['isActive'] ?? false;
                    final String valueDisplay = d['type'] == 'Persentase (%)'
                        ? '${d['value']}%'
                        : currencyFormat.format(d['value']);

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
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
                                      color: isActive
                                          ? Warna.Primary
                                          : Colors.grey,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    d['name'],
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: isActive
                                          ? Colors.black
                                          : Colors.grey[600],
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    valueDisplay,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      color: isActive
                                          ? Warna.Primary
                                          : Colors.grey,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? Colors.green.withValues(alpha: 0.1)
                                          : Colors.grey[200],
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      isActive ? 'Aktif' : 'Non-aktif',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: isActive
                                            ? Colors.green
                                            : Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Divider(height: 1, thickness: 0.5),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(
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
                                  icon: const Icon(TablerIcons.checkbox,
                                      size: 18, color: Colors.green),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                                IconButton(
                                  onPressed: () => _showDiscountForm(
                                    discount: d,
                                    index: index,
                                  ),
                                  icon: const Icon(TablerIcons.edit,
                                      size: 18, color: Colors.blue),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                                IconButton(
                                  onPressed: () => _confirmDelete(index),
                                  icon: const Icon(TablerIcons.trash,
                                      size: 18, color: Colors.red),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                )
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
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? Warna.Primary.withValues(alpha: 0.1)
                                        : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    TablerIcons.discount_2,
                                    color: isActive ? Warna.Primary : Colors.grey,
                                    size: 24,
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
                                              d['name'],
                                              style: GoogleFonts.plusJakartaSans(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: isActive ? Colors.black : Colors.grey[600],
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: isActive ? Colors.green.withValues(alpha: 0.1) : Colors.grey[200],
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              isActive ? 'Aktif' : 'Non-aktif',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: isActive ? Colors.green : Colors.grey[600],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        valueDisplay,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          color: isActive ? Warna.Primary : Colors.grey,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1, thickness: 0.5),
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
                                          builder: (context) => ApplyDiscountPage(
                                            selectedDiscount: d,
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(TablerIcons.checkbox, size: 18),
                                    label: Text(
                                      'Terapkan ke Produk',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    style: TextButton.styleFrom(
                                      iconColor: Colors.green,
                                      foregroundColor: Colors.green,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: () => _showDiscountForm(
                                    discount: d,
                                    index: index,
                                  ),
                                  icon: const Icon(TablerIcons.edit, size: 20, color: Colors.blue),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.blue.withValues(alpha: 0.05),
                                    padding: const EdgeInsets.all(10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: () => _confirmDelete(index),
                                  icon: const Icon(TablerIcons.trash, size: 20, color: Colors.red),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.red.withValues(alpha: 0.05),
                                    padding: const EdgeInsets.all(10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
