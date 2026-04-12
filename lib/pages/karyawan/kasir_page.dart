import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_mobile/CONFIGURATION/CONFIGURATION.dart';
import 'package:tabler_icons/tabler_icons.dart';
import 'package:pos_mobile/COMPONENTS/Components.dart';
import 'package:bounce_tapper/bounce_tapper.dart';
import 'package:pos_mobile/COMPONENTS/ProductCard.dart';
import 'package:pos_mobile/pages/karyawan/checkout_page.dart';
import 'package:intl/intl.dart';

class KasirPage extends StatefulWidget {
  const KasirPage({super.key});

  @override
  State<KasirPage> createState() => _KasirPageState();
}

class _KasirPageState extends State<KasirPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isGridView = true;

  String _selectedCategory = 'Semua';
  String _searchQuery = '';
  Map<String, int> _cartQty = {};
  DateTime _lastButtonTap = DateTime.fromMillisecondsSinceEpoch(0);

  int get totalItems {
    return _cartQty.values.fold(0, (sum, qty) => sum + qty);
  }

  double get totalPrice {
    double total = 0;
    for (var product in products) {
      if (_cartQty.containsKey(product['name'])) {
        total += product['price'] * _cartQty[product['name']]!;
      }
    }
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
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> products = [
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

  List<Map<String, dynamic>> get filteredProducts {
    return products.where((product) {
      final matchesCategory =
          _selectedCategory == 'Semua' ||
          product['category'] == _selectedCategory;
      final matchesSearch = product['name'].toString().toLowerCase().contains(
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
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Warna.Primary,
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
                    color: Warna.Primary,
                  ),
                ),
              ],
            ),
          ),
          _buildCategories(),
          if (products.isEmpty)
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
                      _cartQty.clear();
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
                    _cartQty.forEach((name, qty) {
                      final product =
                          products.firstWhere((p) => p['name'] == name);
                      selectedItems.add({
                        'name': product['name'],
                        'price': product['price'],
                        'image': product['image'],
                        'qty': qty,
                      });
                    });

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CheckoutPage(
                          cartItems: selectedItems,
                        ),
                      ),
                    ).then((_) {
                      // Optional: Clear or refresh cart after coming back if needed
                      // For now, we just let it be.
                    });
                  },
                  backgroundColor: Warna.Primary,
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
              backgroundColor: Warna.Primary,
              child: const Icon(TablerIcons.scan, color: Colors.white),
            ),
    );
  }

  Widget _buildCategories() {
    final categories = ['Semua', 'Minuman', 'Makanan', 'Snack'];
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
            child: myButtonPrimary(
              onPressed: () {
                setState(() {
                  _selectedCategory = categories[index];
                });
              },
              backgroundColor: isSelected ? Warna.Primary : Colors.white,
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
                    padding:
                        const EdgeInsets.only(left: 10, right: 10, bottom: 85),
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
                    padding:
                        const EdgeInsets.only(left: 15, right: 15, bottom: 85),
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

  Widget _buildProductItem(Map<String, dynamic> product, NumberFormat fmt) {
    final int qty = _cartQty[product['name']] ?? 0;
    final bool isSelected = qty > 0;

    return MyProductCard(
      product: product,
      isGridView: _isGridView,
      isSelected: isSelected,
      currencyFormat: fmt,
      quantity: qty,
      onTap: () {
        if (DateTime.now().difference(_lastButtonTap).inMilliseconds < 400)
          return;
        if (!isSelected) {
          setState(() {
            _cartQty[product['name']] = 1;
          });
        }
      },
      onIncrement: () {
        setState(() {
          _lastButtonTap = DateTime.now();
          _cartQty[product['name']] = qty + 1;
        });
      },
      onDecrement: () {
        setState(() {
          _lastButtonTap = DateTime.now();
          if (qty > 1) {
            _cartQty[product['name']] = qty - 1;
          } else {
            _cartQty.remove(product['name']);
          }
        });
      },
    );
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
            myButtonPrimary(
              onPressed: () {
                // Navigasi ke halaman tambah produk (Master Produk)
              },
              backgroundColor: Warna.Primary,
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
