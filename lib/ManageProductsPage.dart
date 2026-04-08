import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_mobile/CONFIGURATION/CONFIGURATION.dart';
import 'package:pos_mobile/COMPONENTS/Components.dart';
import 'package:tabler_icons/tabler_icons.dart';
import 'package:bounce_tapper/bounce_tapper.dart';
import 'package:intl/intl.dart';
import 'package:pos_mobile/manage_categories_page.dart';

class ManageProductsPage extends StatefulWidget {
  const ManageProductsPage({super.key});

  @override
  State<ManageProductsPage> createState() => _ManageProductsPageState();
}

class _ManageProductsPageState extends State<ManageProductsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  // Dummy initial products (In a real app, this would come from a database/API)
  List<Map<String, dynamic>> products = [
    {
      'name': 'Kopi Susu Gula Aren',
      'price': 18000,
      'image': 'https://via.placeholder.com/150',
      'category': 'Minuman',
    },
    {
      'name': 'Americano',
      'price': 15000,
      'image': 'https://via.placeholder.com/150',
      'category': 'Minuman',
    },
    {
      'name': 'Matcha Latte',
      'price': 22000,
      'image': 'https://via.placeholder.com/150',
      'category': 'Minuman',
    },
    {
      'name': 'Roti Bakar Coklat',
      'price': 15000,
      'image': 'https://via.placeholder.com/150',
      'category': 'Makanan',
    },
    {
      'name': 'Kentang Goreng',
      'price': 12000,
      'image': 'https://via.placeholder.com/150',
      'category': 'Snack',
    },
    {
      'name': 'Dimsum Ayam',
      'price': 15000,
      'image': 'https://via.placeholder.com/150',
      'category': 'Snack',
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

  void _showProductForm({Map<String, dynamic>? product, int? index}) {
    final nameController = TextEditingController(text: product?['name'] ?? '');
    final priceController = TextEditingController(
      text: product?['price']?.toString() ?? '',
    );
    String currentCategory = product?['category'] ?? 'Minuman';
    final imageController = TextEditingController(
      text: product?['image'] ?? 'https://via.placeholder.com/150',
    );

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
                      product == null ? 'Tambah Produk' : 'Edit Produk',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    myTextField(
                      controller: nameController,
                      placeholder: 'Nama Produk',
                      labelText: 'Nama Produk',
                    ),
                    const SizedBox(height: 16),
                    myTextField(
                      controller: priceController,
                      placeholder: 'Harga (Contoh: 15000)',
                      labelText: 'Harga',
                      keyboardType: TextInputType.number,
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
                    const SizedBox(height: 16),
                    myTextField(
                      controller: imageController,
                      placeholder: 'URL Gambar',
                      labelText: 'Link Gambar (Opsional)',
                    ),
                    const SizedBox(height: 32),
                    myButtonPrimary(
                      onPressed: () {
                        if (nameController.text.isEmpty ||
                            priceController.text.isEmpty) {
                          MySnackBar(
                            context: context,
                            text: 'Nama dan harga harus diisi!',
                            status: ToastStatus.error,
                          );
                          return;
                        }

                        final newProduct = {
                          'name': nameController.text,
                          'price': int.tryParse(priceController.text) ?? 0,
                          'category': currentCategory,
                          'image': imageController.text,
                        };

                        setState(() {
                          if (product == null) {
                            products.add(newProduct);
                            MySnackBar(
                              context: context,
                              text: 'Produk berhasil ditambahkan',
                              status: ToastStatus.success,
                            );
                          } else {
                            products[index!] = newProduct;
                            MySnackBar(
                              context: context,
                              text: 'Produk berhasil diperbarui',
                              status: ToastStatus.success,
                            );
                          }
                        });

                        Navigator.pop(context);
                      },
                      backgroundColor: Warna.Primary,
                      foregroundColor: Colors.white,
                      child: Text(
                        product == null ? 'Simpan Produk' : 'Update Produk',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 20),
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
              MySnackBar(
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

    return Scaffold(
      backgroundColor: Warna.BG,
      appBar: MyAppBar(title: 'Kelola Produk', isCenter: true),
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
                            final isSelected = categoryName == _selectedCategory;

                            // Calculate count for each category
                            final count = categoryName == 'Semua'
                                ? products.length
                                : products
                                    .where((p) => p['category'] == categoryName)
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
                                      horizontal: 16),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Warna.Primary
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected
                                          ? Warna.Primary
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
                                                  alpha: 0.7)
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
                            color: Warna.Primary,
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

          // Product List
          Expanded(
            child: filteredProducts.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      // Find real index in original list for editing/deleting
                      final originalIndex = products.indexOf(product);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                product['image'],
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey[100],
                                  child: const Icon(
                                    Icons.image,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['name'],
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        product['category'],
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '•',
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        currencyFormat.format(product['price']),
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Warna.Primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => _showProductForm(
                                    product: product,
                                    index: originalIndex,
                                  ),
                                  icon: const Icon(
                                    TablerIcons.edit,
                                    color: Colors.blue,
                                    size: 20,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () =>
                                      _confirmDelete(originalIndex),
                                  icon: const Icon(
                                    TablerIcons.trash,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProductForm(),
        backgroundColor: Warna.Primary,
        icon: const Icon(TablerIcons.plus, color: Colors.white),
        label: const Text(
          'Tambah Produk',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
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
