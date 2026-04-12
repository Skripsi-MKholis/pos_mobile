import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_mobile/CONFIGURATION/CONFIGURATION.dart';
import 'package:pos_mobile/COMPONENTS/Components.dart';
import 'package:tabler_icons/tabler_icons.dart';
import 'package:bounce_tapper/bounce_tapper.dart';
import 'package:intl/intl.dart';
import 'package:pos_mobile/pages/owner/manage_categories_page.dart';
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
      'name': 'Kopi Susu Gula Aren oakwokawokaowkoakwoakwokaokwoakwok',
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
    ).whenComplete(() {
      _isFormOpen = false;
    });
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
              MySnackBar(
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
                    MySnackBar(
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

    return PopScope(
      canPop: !_isSelectionMode,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _isSelectionMode) {
          _exitSelectionMode();
        }
      },
      child: Scaffold(
        backgroundColor: Warna.BG,
        appBar: _isSelectionMode
            ? MyAppBar(
                title: '${_selectedIndices.length} Terpilih',
                leading: IconButton(
                  onPressed: _exitSelectionMode,
                  icon: const Icon(TablerIcons.x, color: Warna.Primary),
                ),
                actions: [
                  IconButton(
                    onPressed: _selectAll,
                    icon: Icon(
                      _selectedIndices.length == filteredProducts.length
                          ? TablerIcons.checkbox
                          : TablerIcons.square,
                      color: Warna.Primary,
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
                          builder: (context) => const ProductOverviewPage(),
                        ),
                      );
                    },
                    icon: const Icon(
                      TablerIcons.presentation,
                      color: Warna.Primary,
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
                      color: Warna.Primary,
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
                backgroundColor: Warna.Primary,
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected
            ? Warna.Primary.withValues(alpha: 0.05)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isSelected
            ? Border.all(color: Warna.Primary.withValues(alpha: 0.3), width: 1)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: BounceTapper(
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
              child: Row(
                children: [
                  if (_isSelectionMode) ...[
                    Icon(
                      isSelected ? TablerIcons.checkbox : TablerIcons.square,
                      color: isSelected ? Warna.Primary : Colors.grey[400],
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                  ],
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
                        child: const Icon(Icons.image, color: Colors.grey),
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
                              style: TextStyle(color: Colors.grey[400]),
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
                ],
              ),
            ),
          ),
          if (!_isSelectionMode)
            Row(
              children: [
                IconButton(
                  onPressed: () =>
                      _showProductForm(product: product, index: originalIndex),
                  icon: const Icon(
                    TablerIcons.edit,
                    color: Colors.blue,
                    size: 20,
                  ),
                ),
                IconButton(
                  onPressed: () => _confirmDelete(originalIndex),
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
  }

  Widget _buildCardItem(
    Map<String, dynamic> product,
    int originalIndex,
    NumberFormat currencyFormat,
  ) {
    final isSelected = _selectedIndices.contains(originalIndex);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isSelected
            ? Border.all(color: Warna.Primary.withOpacity(0.5), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? Warna.Primary.withOpacity(0.1)
                : Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          BounceTapper(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Section
                Expanded(
                  flex: 3,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        child: Image.network(
                          product['image'] ?? 'https://via.placeholder.com/150',
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[100],
                            child: const Center(
                              child: Icon(Icons.image, color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                      // Selection Overlay
                      if (_isSelectionMode)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Warna.Primary.withOpacity(0.2)
                                  : Colors.black.withOpacity(0.1),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                isSelected
                                    ? TablerIcons.checkbox
                                    : TablerIcons.square,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white70,
                                size: 32,
                              ),
                            ),
                          ),
                        ),

                      // Category Badge
                      if (!_isSelectionMode)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Warna.Primary.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              product['category'],
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Details Section
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          product['name'],
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
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
                  ),
                ),
              ],
            ),
          ),
          // Actions (Edit/Delete) overlay - moved outside main BounceTapper
          if (!_isSelectionMode)
            Positioned(
              top: 4,
              right: 4,
              child: Row(
                children: [
                  _buildMiniAction(
                    icon: TablerIcons.edit,
                    color: Colors.blue,
                    onTap: () => _showProductForm(
                      product: product,
                      index: originalIndex,
                    ),
                  ),
                  const SizedBox(width: 4),
                  _buildMiniAction(
                    icon: TablerIcons.trash,
                    color: Colors.red,
                    onTap: () => _confirmDelete(originalIndex),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMiniAction({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return BounceTapper(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 14, color: color),
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
