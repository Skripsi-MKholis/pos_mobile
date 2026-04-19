import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tabler_icons/tabler_icons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../configuration/configuration.dart';
import 'package:pos_mobile/components/components.dart';
import '../../components/product_card.dart';
import '../../providers/auth_provider.dart';
import '../../repositories/product_repository.dart';
import '../../repositories/master_repository.dart';
import '../../models/product_model.dart';
import 'checkout_page.dart';

class KasirPage extends StatefulWidget {
  const KasirPage({super.key});

  @override
  State<KasirPage> createState() => _KasirPageState();
}

class _KasirPageState extends State<KasirPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isGridView = true;
  bool _isLoading = true;

  List<ProductModel> _allProducts = [];
  List<String> _categories = ['Semua'];

  String _selectedCategory = 'Semua';
  String _searchQuery = '';
  // Each item: { 'id': String, 'qty': int, 'selectedVariants': List<Map> }
  // For simplicity since current products use 'name' as identifier:
  // Item key: name + | + variant_slug
  final Map<String, Map<String, dynamic>> _cart = {};
  DateTime _lastButtonTap = DateTime.fromMillisecondsSinceEpoch(0);

  int get totalItems {
    return _cart.values.fold(0, (sum, item) => sum + (item['qty'] as int));
  }

  double get totalPrice {
    double total = 0;
    _cart.forEach((key, item) {
      total += (item['totalPrice'] as num) * (item['qty'] as int);
    });
    return total;
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final auth = context.read<AuthProvider>();
      final storeId = auth.selectedStore?.id;
      
      if (storeId == null) {
        throw Exception('Tidak ada toko yang dipilih');
      }

      final productRepo = context.read<ProductRepository>();
      final masterRepo = context.read<MasterRepository>();

      final products = await productRepo.getProducts(storeId);
      final categories = await masterRepo.getCategories(storeId);

      if (mounted) {
        setState(() {
          _allProducts = products;
          _categories = ['Semua', ...categories.map((c) => c['name'] as String)];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        mySnackBar(
          context: context,
          text: 'Gagal memuat data produk: $e',
          status: ToastStatus.error,
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ProductModel> get filteredProducts {
    return _allProducts.where((product) {
      final matchesCategory =
          _selectedCategory == 'Semua' ||
          product.category == _selectedCategory;
      final matchesSearch = product.name.toLowerCase().contains(
        _searchQuery,
      );
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: myTextField(
                    controller: _searchController,
                    placeholder: 'Cari produk...',
                    labelText: 'Cari Produk',
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Warna.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(TablerIcons.barcode, color: Colors.white),
                ),
                const SizedBox(width: 10),
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
              ],
            ),
          ),
          _buildCategories(),
          if (_isLoading)
            Expanded(
              child: Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
                  color: Warna.primary,
                  size: 50,
                ),
              ),
            )
          else if (_allProducts.isEmpty)
            _buildNoProduct()
          else if (filteredProducts.isEmpty)
            _buildEmpty()
          else
            _buildProductGrid(),
        ],
      ),
      floatingActionButton: totalItems > 0
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: 'clearBtn',
                  onPressed: () {
                    setState(() {
                      _cart.clear();
                    });
                  },
                  backgroundColor: Colors.redAccent,
                  child: const Icon(TablerIcons.x, color: Colors.white),
                ),
                const SizedBox(width: 10),
                FloatingActionButton.extended(
                  heroTag: 'checkoutBtn',
                  onPressed: () {
                    List<Map<String, dynamic>> selectedItems = [];
                    _cart.forEach((key, item) {
                      selectedItems.add(Map<String, dynamic>.from(item));
                    });

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CheckoutPage(cartItems: selectedItems),
                      ),
                    );
                  },
                  backgroundColor: Warna.primary,
                  icon: const Icon(
                    TablerIcons.shopping_cart,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Checkout ($totalItems)',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            )
          : FloatingActionButton(
              heroTag: 'scanBtn',
              onPressed: () {
                // Navigasi ke scanner atau show modal
              },
              backgroundColor: Warna.primary,
              child: const Icon(TablerIcons.scan, color: Colors.white),
            ),
    );
  }

  Widget _buildCategories() {
    final categories = _categories;
    return Container(
      height: 60,
      alignment: Alignment.center,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isSelected = categories[index] == _selectedCategory;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
            child: MyButtonPrimary(
              onPressed: () {
                setState(() {
                  _selectedCategory = categories[index];
                });
              },
              backgroundColor: isSelected ? Warna.primary : Colors.white,
              foregroundColor: isSelected ? Colors.white : Colors.black,
              isOutlined: !isSelected,
              width: null,
              radius: 20,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 0,
                ),
                child: Center(
                  child: Text(
                    categories[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid() {
    final fmt = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: _isGridView
                ? GridView.builder(
                    padding: const EdgeInsets.only(
                      left: 10,
                      right: 10,
                      bottom: 85,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.72,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return _buildProductItem(product, fmt);
                    },
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(
                      left: 15,
                      right: 15,
                      bottom: 85,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return _buildProductItem(product, fmt);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  int _getProductQty(String productName) {
    int total = 0;
    _cart.forEach((key, item) {
      if (item['name'] == productName) {
        total += (item['qty'] as int);
      }
    });
    return total;
  }

  Widget _buildProductItem(ProductModel product, NumberFormat fmt) {
    final int qty = _getProductQty(product.name);
    final bool isSelected = qty > 0;
    // For now, variants is always empty in ProductModel if not handled yet
    // But original UI had it. Let's keep logic simple.

    return MyProductCard(
      product: product.toMap(), // Keep using Map for card for now or update Card
      isGridView: _isGridView,
      isSelected: isSelected,
      currencyFormat: fmt,
      quantity: qty,
      onTap: () {
        if (DateTime.now().difference(_lastButtonTap).inMilliseconds < 400) {
          return;
        }
        _showProductNoteModal(product.toMap());
      },
      onIncrement: () {
        _showProductNoteModal(product.toMap());
      },
      onDecrement: () {
        _decrementLegacy(product.name);
      },
    );
  }

  void _showProductNoteModal(Map<String, dynamic> product) {
    final TextEditingController noteController = TextEditingController();
    final fmt = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[200]!),
                    ),
                  ),
                  child: Row(
                    children: [
                      MyNetworkImage(
                        imageUrl: product['image'],
                        width: 50,
                        height: 50,
                        borderRadius: 8,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['name'],
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              fmt.format(product['price']),
                              style: GoogleFonts.plusJakartaSans(
                                color: Warna.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(TablerIcons.x),
                      ),
                    ],
                  ),
                ),

                // Note Input
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Catatan Pesanan',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      myTextField(
                        controller: noteController,
                        placeholder: 'Contoh: Kurangi es, pedas, dll.',
                      ),
                    ],
                  ),
                ),

                // Footer ADD Button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: MyButtonPrimary(
                    onPressed: () {
                      _addToCart(product, note: noteController.text);
                      Navigator.pop(context);
                    },
                    backgroundColor: Warna.primary,
                    foregroundColor: Colors.white,
                    child: const Center(
                      child: Text(
                        'Tambah ke Keranjang',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addToCart(
    Map<String, dynamic> product, {
    List<Map<String, dynamic>>? selectedOptions,
    double? customPrice,
    String? note,
  }) {
    setState(() {
      _lastButtonTap = DateTime.now();
      String variantNames = '';
      if (selectedOptions != null && selectedOptions.isNotEmpty) {
        variantNames = selectedOptions.map((o) => o['name']).join(',');
      }

      // Key includes variants and note to allow separate entries for same product with different notes
      String key = '${product['name']}|$variantNames|${note ?? ''}';

      if (_cart.containsKey(key)) {
        _cart[key]!['qty']++;
      } else {
        _cart[key] = {
          'name': product['name'],
          'price': product['price'], // Original price
          'totalPrice':
              customPrice ??
              product['price'], // Final price after all adjustments
          'image': product['image'],
          'qty': 1,
          'selectedOptions': selectedOptions ?? [],
          'note': note ?? '',
          'appliedDiscount': product['appliedDiscount'],
          'stock': product['stock'],
          'isInfiniteStock': product['isInfiniteStock'],
        };
      }
    });
  }

  void _decrementLegacy(String productName) {
    setState(() {
      _lastButtonTap = DateTime.now();
      // Find the first matching item in cart to decrement
      String? keyToModify;
      for (var key in _cart.keys) {
        if (_cart[key]!['name'] == productName) {
          keyToModify = key;
          break;
        }
      }

      if (keyToModify != null) {
        if (_cart[keyToModify]!['qty'] > 1) {
          _cart[keyToModify]!['qty']--;
        } else {
          _cart.remove(keyToModify);
        }
      }
    });
  }


  Widget _buildEmpty() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(TablerIcons.box_off, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Produk Tidak Ditemukan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cari dengan kata kunci lain\natau pilih kategori lainnya.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoProduct() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Belum Ada Produk',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Silakan tambahkan produk pertama Anda\nuntuk mulai berjualan.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            MyButtonPrimary(
              onPressed: () {
                // Navigasi ke halaman tambah produk (Master Produk)
              },
              backgroundColor: Warna.primary,
              foregroundColor: Colors.white,
              isOutlined: false,
              width: 200,
              radius: 12,
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(TablerIcons.plus, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Tambah Produk',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
