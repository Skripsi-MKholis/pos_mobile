import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_mobile/configuration/configuration.dart';
import 'package:pos_mobile/components/components.dart';
import 'package:tabler_icons/tabler_icons.dart';
import 'package:bounce_tapper/bounce_tapper.dart';
import 'package:intl/intl.dart';
import 'package:pos_mobile/components/product_card.dart';
import 'package:pos_mobile/pages/owner/manage_categories_page.dart';
import 'package:pos_mobile/pages/owner/manage_discounts_page.dart';
import 'package:pos_mobile/pages/owner/product_overview_page.dart';

class ManageProductsPage extends StatefulWidget {
  const ManageProductsPage({super.key});

  @override
  State<ManageProductsPage> createState() => _ManageProductsPageState();
}

class _ManageProductsPageState extends State<ManageProductsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Semua';
  bool _isGridView = false;
  final Set<int> _selectedIndices = {};
  bool get _isSelectionMode => _selectedIndices.isNotEmpty;
  bool _isLongPressing = false;
  bool _isFormOpen = false;

  // Dummy initial products (In a real app, this would come from a database/API)
  List<Map<String, dynamic>> products = [
    {
      'name': 'Kopi Susu Gula Aren',
      'price': 18000,
      'modalPrice': 12000,
      'image': 'https://via.placeholder.com/150',
      'category': 'Minuman',
      'stock': 50,
      'isInfiniteStock': false,
      'barcode': '8991234567',
      'description': 'Kopi Susu segar dengan gula aren murni.',
      'variants': [],
      'appliedDiscount': {
        'name': 'Promo Awal Tahun',
        'type': 'Persentase (%)',
        'value': 10,
      },
    },
    {
      'name': 'Americano',
      'price': 15000,
      'modalPrice': 8000,
      'image': 'https://via.placeholder.com/150',
      'category': 'Minuman',
      'stock': 100,
      'isInfiniteStock': true,
      'barcode': '8991234568',
      'description': 'Kopi hitam murni tanpa ampas.',
      'variants': [],
    },
    {
      'name': 'Matcha Latte',
      'price': 22000,
      'modalPrice': 15000,
      'image': 'https://via.placeholder.com/150',
      'category': 'Minuman',
      'stock': 30,
      'isInfiniteStock': false,
      'barcode': '8991234569',
      'description': 'Bubuk matcha berkualitas dengan susu creamy.',
      'variants': [],
    },
    {
      'name': 'Roti Bakar Coklat',
      'price': 15000,
      'modalPrice': 10000,
      'image': 'https://via.placeholder.com/150',
      'category': 'Makanan',
      'stock': 20,
      'isInfiniteStock': false,
      'barcode': '8991234570',
      'description': 'Roti bakar dengan selai coklat melimpah.',
      'variants': [],
    },
  ];

  List<String> categories = ['Semua', 'Minuman', 'Makanan', 'Snack'];

  List<Map<String, dynamic>> get filteredProducts {
    return products.where((product) {
      final matchesCategory =
          _selectedCategory == 'Semua' ||
          product['category'] == _selectedCategory;
      final matchesSearch = product['name'].toString().toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _exitSelectionMode() {
    setState(() {
      _selectedIndices.clear();
    });
  }

  void _showProductForm({Map<String, dynamic>? product, int? index}) {
    if (_isFormOpen) return;
    _isFormOpen = true;

    final nameController = TextEditingController(text: product?['name'] ?? '');
    final priceController = TextEditingController(
      text: product?['price']?.toString() ?? '',
    );
    final modalPriceController = TextEditingController(
      text: product?['modalPrice']?.toString() ?? '',
    );
    final stockController = TextEditingController(
      text: product?['stock']?.toString() ?? '',
    );
    final barcodeController = TextEditingController(
      text: product?['barcode'] ?? '',
    );
    final descriptionController = TextEditingController(
      text: product?['description'] ?? '',
    );

    String currentCategory = product?['category'] ?? 'Minuman';
    String? currentImage = product?['image'];
    bool isInfiniteStock = product?['isInfiniteStock'] ?? false;
    List<Map<String, dynamic>> productVariants =
        product?['variants'] != null
            ? List<Map<String, dynamic>>.from(
              (product!['variants'] as List).map(
                (v) => Map<String, dynamic>.from(v),
              ),
            )
            : [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero, // Fullscreen style
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(TablerIcons.x, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  product == null ? 'Tambah Produk' : 'Edit Produk',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                centerTitle: true,
                actions: [
                  TextButton(
                    onPressed: () {
                      if (nameController.text.isEmpty ||
                          priceController.text.isEmpty) {
                        mySnackBar(
                          context: context,
                          text: 'Nama dan harga jual harus diisi!',
                          status: ToastStatus.error,
                        );
                        return;
                      }

                      final newProduct = {
                        'name': nameController.text,
                        'price': int.tryParse(priceController.text) ?? 0,
                        'modalPrice':
                            int.tryParse(modalPriceController.text) ?? 0,
                        'category': currentCategory,
                        'image':
                            currentImage ?? 'https://via.placeholder.com/150',
                        'stock':
                            isInfiniteStock
                                ? 0
                                : int.tryParse(stockController.text) ?? 0,
                        'isInfiniteStock': isInfiniteStock,
                        'barcode': barcodeController.text,
                        'description': descriptionController.text,
                        'variants': productVariants,
                      };

                      setState(() {
                        if (product == null) {
                          products.add(newProduct);
                          mySnackBar(
                            context: context,
                            text: 'Produk berhasil ditambahkan',
                            status: ToastStatus.success,
                          );
                        } else {
                          products[index!] = newProduct;
                          mySnackBar(
                            context: context,
                            text: 'Produk berhasil diperbarui',
                            status: ToastStatus.success,
                          );
                        }
                      });

                      Navigator.pop(context);
                    },
                    child: Text(
                      'Simpan',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        color: Warna.primary,
                      ),
                    ),
                  ),
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Upload Placeholder
                    myInputFile(
                      labelText: 'Foto Produk',
                      fileName:
                          currentImage != null ? 'Gambar terpilih' : null,
                      onTap: () {
                        // In a real app, use image_picker here
                        setModalState(() {
                          currentImage = 'https://via.placeholder.com/150';
                        });
                        mySnackBar(
                          context: context,
                          text: 'Gambar dipilih (Placeholder)',
                          status: ToastStatus.info,
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    myTextField(
                      controller: nameController,
                      placeholder: 'Contoh: Kopi Susu',
                      labelText: 'Nama Produk',
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: myTextField(
                            controller: priceController,
                            placeholder: '0',
                            labelText: 'Harga Jual',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: myTextField(
                            controller: modalPriceController,
                            placeholder: '0',
                            labelText: 'Harga Modal',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    mySelectField(
                      labelText: 'Kategori',
                      selectedValue: currentCategory,
                      items: categories.where((c) => c != 'Semua').toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setModalState(() {
                            currentCategory = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 20),

                    // Stock Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Stok Tak Terbatas',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Switch(
                          value: isInfiniteStock,
                          activeThumbColor: Warna.primary,
                          onChanged: (val) {
                            setModalState(() {
                              isInfiniteStock = val;
                            });
                          },
                        ),
                      ],
                    ),
                    if (!isInfiniteStock)
                      myTextField(
                        controller: stockController,
                        placeholder: '0',
                        labelText: 'Jumlah Stok',
                        keyboardType: TextInputType.number,
                      ),
                    const SizedBox(height: 16),

                    // Barcode Section
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: myTextField(
                            controller: barcodeController,
                            placeholder: 'Barcode / SKU',
                            labelText: 'Barcode',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          margin: const EdgeInsets.only(bottom: 2),
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              final timestamp =
                                  DateTime.now().millisecondsSinceEpoch.toString();
                              barcodeController.text =
                                  timestamp.substring(timestamp.length - 10);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Warna.primary.withValues(alpha: 0.1),
                              foregroundColor: Warna.primary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(TablerIcons.refresh, size: 18),
                            label: const Text('Auto'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    myTextField(
                      controller: descriptionController,
                      placeholder: 'Tulis deskripsi produk...',
                      labelText: 'Deskripsi (Opsional)',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),

                    // Variants Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Varian Produk',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => _showVariantForm(
                            context: context,
                            onSave: (newVariant) {
                              setModalState(() {
                                productVariants.add(newVariant);
                              });
                            },
                          ),
                          icon: const Icon(TablerIcons.plus, size: 18),
                          label: const Text('Tambah Varian'),
                          style: TextButton.styleFrom(
                            foregroundColor: Warna.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    if (productVariants.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Warna.bg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Center(
                          child: Text(
                            'Belum ada varian',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.grey[500],
                              fontSize: 13,
                            ),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: productVariants.length,
                        itemBuilder: (context, vIndex) {
                          final variant = productVariants[vIndex];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        variant['name'],
                                        style: GoogleFonts.plusJakartaSans(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        '${variant['options'].length} Opsi • ${variant['priceType']}',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setModalState(() {
                                      productVariants.removeAt(vIndex);
                                    });
                                  },
                                  icon: const Icon(
                                    TablerIcons.trash,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      _isFormOpen = false;
    });
  }

  void _showVariantForm({
    required BuildContext context,
    required Function(Map<String, dynamic>) onSave,
  }) {
    final variantNameController = TextEditingController();
    bool isRequired = false;
    bool allowMultiple = false;
    String priceType = 'Tambah Harga'; // Default
    List<Map<String, dynamic>> options = [];

    // Helper to add option
    void addOption(StateSetter setVState) {
      final nameCtrl = TextEditingController();
      final priceCtrl = TextEditingController();
      setVState(() {
        options.add({
          'controller_name': nameCtrl,
          'controller_price': priceCtrl,
        });
      });
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setVState) {
            return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(TablerIcons.arrow_left, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  'Tambah Varian',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                centerTitle: true,
                actions: [
                  TextButton(
                    onPressed: () {
                      if (variantNameController.text.isEmpty) {
                        mySnackBar(
                          context: context,
                          text: 'Nama varian harus diisi!',
                          status: ToastStatus.error,
                        );
                        return;
                      }
                      if (options.isEmpty) {
                        mySnackBar(
                          context: context,
                          text: 'Minimal tambah 1 opsi!',
                          status: ToastStatus.error,
                        );
                        return;
                      }

                      final finalOptions =
                          options.map((opt) {
                            return {
                              'name': (opt['controller_name'] as TextEditingController).text,
                              'price': int.tryParse((opt['controller_price'] as TextEditingController).text) ?? 0,
                            };
                          }).toList();

                      onSave({
                        'name': variantNameController.text,
                        'isRequired': isRequired,
                        'allowMultiple': allowMultiple,
                        'priceType': priceType,
                        'options': finalOptions,
                      });

                      Navigator.pop(context);
                    },
                    child: Text(
                      'Simpan',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        color: Warna.primary,
                      ),
                    ),
                  ),
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    myTextField(
                      controller: variantNameController,
                      placeholder: 'Contoh: Ukuran atau Topping',
                      labelText: 'Nama Varian',
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Wajib Dipilih',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Switch(
                          value: isRequired,
                          activeThumbColor: Warna.primary,
                          onChanged: (val) => setVState(() => isRequired = val),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Bisa Pilih Banyak',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Switch(
                          value: allowMultiple,
                          activeThumbColor: Warna.primary,
                          onChanged: (val) => setVState(() => allowMultiple = val),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    mySelectField(
                      labelText: 'Tipe Harga',
                      selectedValue: priceType,
                      items: ['Tambah Harga', 'Ganti Harga Utama'],
                      onChanged: (val) {
                        if (val != null) {
                          setVState(() => priceType = val);
                        }
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Text(
                        priceType == 'Tambah Harga'
                            ? 'Harga opsi akan ditambahkan ke harga produk utama (Contoh: +Rp 5.000)'
                            : 'Harga opsi akan menggantikan harga produk utama (Contoh: Menjadi Rp 25.000)',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'Daftar Opsi',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),

                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: options.length,
                      itemBuilder: (context, oIndex) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: myTextField(
                                  controller: options[oIndex]['controller_name'],
                                  placeholder: 'Nama Opsi',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: myTextField(
                                  controller: options[oIndex]['controller_price'],
                                  placeholder: 'Harga +',
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setVState(() {
                                    options.removeAt(oIndex);
                                  });
                                },
                                icon: const Icon(
                                  TablerIcons.circle_minus,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    MyButtonPrimary(
                      onPressed: () => addOption(setVState),
                      backgroundColor: Warna.primary.withValues(alpha: 0.1),
                      foregroundColor: Warna.primary,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(TablerIcons.plus, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Tambah Opsi',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _bulkDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Hapus Produk Terpilih?',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus ${_selectedIndices.length} produk yang dipilih?',
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
                // Sort indices descending to avoid shifting issues during removal
                final sortedIndices = _selectedIndices.toList()
                  ..sort((a, b) => b.compareTo(a));

                for (var index in sortedIndices) {
                  products.removeAt(index);
                }
                _selectedIndices.clear();
              });
              Navigator.pop(context);
              mySnackBar(
                context: context,
                text: 'Produk terpilih berhasil dihapus',
                status: ToastStatus.success,
              );
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _bulkChangeCategory() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Ubah Kategori Massal',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: categories.where((c) => c != 'Semua').toList().length,
              itemBuilder: (context, index) {
                final cat = categories
                    .where((c) => c != 'Semua')
                    .toList()[index];
                return ListTile(
                  title: Text(cat, style: GoogleFonts.plusJakartaSans()),
                  onTap: () {
                    setState(() {
                      for (var index in _selectedIndices) {
                        products[index]['category'] = cat;
                      }
                      _selectedIndices.clear();
                    });
                    Navigator.pop(context);
                    mySnackBar(
                      context: context,
                      text: 'Kategori produk terpilih berhasil diubah',
                      status: ToastStatus.success,
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _selectAll() {
    // We need to select indices from the filtered list?
    // Usually, "Select All" affects the current view.
    // For simplicity, let's select all indices of products in the current filtered list.
    setState(() {
      final filteredIndices = products
          .asMap()
          .entries
          .where((entry) {
            final product = entry.value;
            final matchesCategory =
                _selectedCategory == 'Semua' ||
                product['category'] == _selectedCategory;
            final matchesSearch = product['name']
                .toString()
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());
            return matchesCategory && matchesSearch;
          })
          .map((entry) => entry.key)
          .toList();

      if (_selectedIndices.length == filteredIndices.length) {
        _selectedIndices.clear();
      } else {
        _selectedIndices.addAll(filteredIndices);
      }
    });
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Hapus Produk?',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus produk "${products[index]['name']}"?',
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
                products.removeAt(index);
              });
              Navigator.pop(context);
              mySnackBar(
                context: context,
                text: 'Produk berhasil dihapus',
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

    return PopScope(
      canPop: !_isSelectionMode,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _isSelectionMode) {
          _exitSelectionMode();
        }
      },
      child: Scaffold(
        backgroundColor: Warna.bg,
        appBar: _isSelectionMode
            ? MyAppBar(
                title: '${_selectedIndices.length} Terpilih',
                leading: IconButton(
                  onPressed: _exitSelectionMode,
                  icon: const Icon(TablerIcons.x, color: Warna.primary),
                ),
                actions: [
                  IconButton(
                    onPressed: _selectAll,
                    icon: Icon(
                      _selectedIndices.length == filteredProducts.length
                          ? TablerIcons.checkbox
                          : TablerIcons.square,
                      color: Warna.primary,
                    ),
                  ),
                  IconButton(
                    onPressed: _bulkChangeCategory,
                    icon: const Icon(
                      TablerIcons.category,
                      color: Colors.orange,
                    ),
                  ),
                  IconButton(
                    onPressed: _bulkDelete,
                    icon: const Icon(TablerIcons.trash, color: Colors.red),
                  ),
                  const SizedBox(width: 8),
                ],
              )
            : MyAppBar(
                title: 'Kelola Produk',
                isCenter: true,
                actions: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ManageDiscountsPage(),
                        ),
                      );
                    },
                    icon: const Icon(
                      TablerIcons.discount_2,
                      color: Warna.primary,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProductOverviewPage(),
                        ),
                      );
                    },
                    icon: const Icon(
                      TablerIcons.presentation,
                      color: Warna.primary,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _isGridView = !_isGridView;
                      });
                    },
                    icon: Icon(
                      _isGridView ? TablerIcons.list : TablerIcons.layout_grid,
                      color: Warna.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
        body: Column(
          children: [
            // Search & Filter Section
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                children: [
                  myTextField(
                    controller: _searchController,
                    placeholder: 'Cari produk berdasarkan nama...',
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 40,
                    child: Row(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: categories.length,
                            itemBuilder: (context, index) {
                              final categoryName = categories[index];
                              final isSelected =
                                  categoryName == _selectedCategory;

                              // Calculate count for each category
                              final count = categoryName == 'Semua'
                                  ? products.length
                                  : products
                                        .where(
                                          (p) => p['category'] == categoryName,
                                        )
                                        .length;

                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: BounceTapper(
                                  onTap: () {
                                    setState(() {
                                      _selectedCategory = categoryName;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Warna.primary
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isSelected
                                            ? Warna.primary
                                            : Colors.grey[300]!,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          categoryName,
                                          style: GoogleFonts.plusJakartaSans(
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.black87,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '($count)',
                                          style: GoogleFonts.plusJakartaSans(
                                            color: isSelected
                                                ? Colors.white.withValues(
                                                    alpha: 0.7,
                                                  )
                                                : Colors.grey[500],
                                            fontWeight: FontWeight.normal,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        BounceTapper(
                          onTap: () async {
                            final updatedCategories = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ManageCategoriesPage(
                                  currentCategories: categories,
                                ),
                              ),
                            );

                            if (updatedCategories != null &&
                                updatedCategories is List<String>) {
                              setState(() {
                                categories = updatedCategories;
                                // Reset category if the selected one is gone
                                if (!categories.contains(_selectedCategory)) {
                                  _selectedCategory = 'Semua';
                                }
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Icon(
                              TablerIcons.settings,
                              color: Warna.primary,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: filteredProducts.isEmpty
                  ? _buildEmptyState()
                  : _isGridView
                  ? GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        final originalIndex = products.indexOf(product);
                        return _buildCardItem(
                          product,
                          originalIndex,
                          currencyFormat,
                        );
                      },
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        final originalIndex = products.indexOf(product);
                        return _buildListItem(
                          product,
                          originalIndex,
                          currencyFormat,
                        );
                      },
                    ),
            ),
          ],
        ),
        floatingActionButton: _isSelectionMode
            ? null
            : FloatingActionButton.extended(
                onPressed: () => _showProductForm(),
                backgroundColor: Warna.primary,
                icon: const Icon(TablerIcons.plus, color: Colors.white),
                label: const Text(
                  'Tambah Produk',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildListItem(
    Map<String, dynamic> product,
    int originalIndex,
    NumberFormat currencyFormat,
  ) {
    final isSelected = _selectedIndices.contains(originalIndex);

    return MyProductCard(
      product: product,
      isGridView: false,
      isSelected: isSelected,
      isSelectionMode: _isSelectionMode,
      showActions: !_isSelectionMode,
      currencyFormat: currencyFormat,
      onTap: () {
        if (_isLongPressing) {
          _isLongPressing = false;
          return;
        }

        if (_isSelectionMode) {
          setState(() {
            if (isSelected) {
              _selectedIndices.remove(originalIndex);
            } else {
              _selectedIndices.add(originalIndex);
            }
          });
        } else {
          _showProductForm(product: product, index: originalIndex);
        }
      },
      onLongPress: () {
        if (!_isSelectionMode) {
          setState(() {
            _isLongPressing = true;
            _selectedIndices.add(originalIndex);
          });
        }
      },
      onEdit: () => _showProductForm(product: product, index: originalIndex),
      onDelete: () => _confirmDelete(originalIndex),
    );
  }

  Widget _buildCardItem(
    Map<String, dynamic> product,
    int originalIndex,
    NumberFormat currencyFormat,
  ) {
    final isSelected = _selectedIndices.contains(originalIndex);

    return MyProductCard(
      product: product,
      isGridView: true,
      isSelected: isSelected,
      isSelectionMode: _isSelectionMode,
      showActions: !_isSelectionMode,
      currencyFormat: currencyFormat,
      onTap: () {
        if (_isLongPressing) {
          _isLongPressing = false;
          return;
        }

        if (_isSelectionMode) {
          setState(() {
            if (isSelected) {
              _selectedIndices.remove(originalIndex);
            } else {
              _selectedIndices.add(originalIndex);
            }
          });
        } else {
          _showProductForm(product: product, index: originalIndex);
        }
      },
      onLongPress: () {
        if (!_isSelectionMode) {
          setState(() {
            _isLongPressing = true;
            _selectedIndices.add(originalIndex);
          });
        }
      },
      onEdit: () => _showProductForm(product: product, index: originalIndex),
      onDelete: () => _confirmDelete(originalIndex),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(TablerIcons.package, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Produk tidak ditemukan',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coba cari dengan kata kunci lain',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
