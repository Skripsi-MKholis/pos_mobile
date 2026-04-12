import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_mobile/CONFIGURATION/CONFIGURATION.dart';
import 'package:pos_mobile/COMPONENTS/Components.dart';
import 'package:tabler_icons/tabler_icons.dart';
import 'package:bounce_tapper/bounce_tapper.dart';

class ApplyCategoryPage extends StatefulWidget {
  final String categoryName;

  const ApplyCategoryPage({super.key, required this.categoryName});

  @override
  State<ApplyCategoryPage> createState() => _ApplyCategoryPageState();
}

class _ApplyCategoryPageState extends State<ApplyCategoryPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategoryFilter = 'Semua';
  final Set<int> _selectedProductIndices = {};

  // Mock categories for filtering
  final List<String> categories = [
    'Semua',
    'Makanan',
    'Minuman',
    'Snack',
    'Dessert',
  ];

  // Dummy products (same as ManageProductsPage/ApplyDiscountPage)
  final List<Map<String, dynamic>> products = [
    {
      'name': 'Kopi Susu Gula Aren',
      'price': 18000,
      'category': 'Minuman',
      'image': 'https://via.placeholder.com/150',
    },
    {
      'name': 'Americano',
      'price': 15000,
      'category': 'Minuman',
      'image': 'https://via.placeholder.com/150',
    },
    {
      'name': 'Matcha Latte',
      'price': 22000,
      'category': 'Minuman',
      'image': 'https://via.placeholder.com/150',
    },
    {
      'name': 'Nasi Goreng Spesial',
      'price': 25000,
      'category': 'Makanan',
      'image': 'https://via.placeholder.com/150',
    },
    {
      'name': 'Mie Goreng Seafood',
      'price': 28000,
      'category': 'Makanan',
      'image': 'https://via.placeholder.com/150',
    },
    {
      'name': 'Kentang Goreng',
      'price': 15000,
      'category': 'Snack',
      'image': 'https://via.placeholder.com/150',
    },
  ];

  List<Map<String, dynamic>> get filteredProducts {
    return products.where((product) {
      final matchesCategory =
          _selectedCategoryFilter == 'Semua' ||
          product['category'] == _selectedCategoryFilter;
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

  void _toggleProductSelection(int index) {
    setState(() {
      if (_selectedProductIndices.contains(index)) {
        _selectedProductIndices.remove(index);
      } else {
        _selectedProductIndices.add(index);
      }
    });
  }

  void _applyCategory() {
    if (_selectedProductIndices.isEmpty) {
      MySnackBar(
        context: context,
        text: 'Pilih minimal satu produk!',
        status: ToastStatus.error,
      );
      return;
    }

    // Process logic here...
    // In this mock, we just pop back
    Navigator.pop(context);
    MySnackBar(
      context: context,
      text:
          'Berhasil menambahkan ${_selectedProductIndices.length} produk ke kategori ${widget.categoryName}',
      status: ToastStatus.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Warna.BG,
      appBar: MyAppBar(title: 'Tambah ke Kategori', isCenter: true),
      body: Column(
        children: [
          // Target Category Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Warna.Primary.withValues(alpha: 0.1),
              border: Border(
                bottom: BorderSide(color: Warna.Primary.withValues(alpha: 0.2)),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    TablerIcons.category,
                    color: Warna.Primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Target Kategori',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        widget.categoryName,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Search & Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                myTextField(
                  controller: _searchController,
                  placeholder: 'Cari produk...',
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 36,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      final isSel = cat == _selectedCategoryFilter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: BounceTapper(
                          onTap: () => setState(() => _selectedCategoryFilter = cat),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSel ? Warna.Primary : Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isSel
                                    ? Warna.Primary
                                    : Colors.grey[300]!,
                              ),
                            ),
                            child: Text(
                              cat,
                              style: GoogleFonts.plusJakartaSans(
                                color: isSel ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      final originalIndex = products.indexOf(product);
                      final isSelected = _selectedProductIndices.contains(
                        originalIndex,
                      );

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? Warna.Primary.withValues(alpha: 0.5)
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: CheckboxListTile(
                          value: isSelected,
                          onChanged: (val) =>
                              _toggleProductSelection(originalIndex),
                          activeColor: Warna.Primary,
                          checkboxShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          title: Text(
                            product['name'],
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            product['category'],
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: product['category'] == widget.categoryName 
                                ? Warna.Primary 
                                : Colors.grey[600],
                              fontWeight: product['category'] == widget.categoryName 
                                ? FontWeight.bold 
                                : FontWeight.normal,
                            ),
                          ),
                          secondary: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              product['image'],
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                          controlAffinity: ListTileControlAffinity.trailing,
                        ),
                      );
                    },
                  ),
          ),

          // Action Button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: myButtonPrimary(
              onPressed: _applyCategory,
              backgroundColor: Warna.Primary,
              foregroundColor: Colors.white,
              child: Text(
                _selectedProductIndices.isEmpty
                    ? 'Pilih Produk'
                    : 'Masukan (${_selectedProductIndices.length}) Produk ke Kategori',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(TablerIcons.search_off, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Produk tidak ditemukan',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
