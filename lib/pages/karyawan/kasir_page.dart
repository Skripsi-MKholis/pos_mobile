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
  // Each item: { 'id': String, 'qty': int, 'selectedVariants': List<Map> }
  // For simplicity since current products use 'name' as identifier:
  // Item key: name + | + variant_slug
  Map<String, Map<String, dynamic>> _cart = {};
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
      'stock': 50,
      'isInfiniteStock': false,
      'isBestSeller': true,
      'variants': [
        {
          'name': 'Ukuran',
          'isRequired': true,
          'allowMultiple': false,
          'priceType': 'Tambah Harga',
          'options': [
            {'name': 'Regular', 'price': 0},
            {'name': 'Large', 'price': 5000},
          ],
        },
        {
          'name': 'Topping',
          'isRequired': false,
          'allowMultiple': true,
          'priceType': 'Tambah Harga',
          'options': [
            {'name': 'Cincau', 'price': 2000},
            {'name': 'Boba', 'price': 3000},
            {'name': 'Jelly', 'price': 2000},
          ],
        },
      ],
    },
    {
      'name': 'Americano',
      'price': 15000,
      'image': 'https://via.placeholder.com/150',
      'category': 'Minuman',
      'stock': 100,
      'isInfiniteStock': true,
      'appliedDiscount': {
        'name': 'Promo Heboh',
        'type': 'Persentase (%)',
        'value': 15,
      },
      'variants': [],
    },
    {
      'name': 'Matcha Latte',
      'price': 22000,
      'image': 'https://via.placeholder.com/150',
      'category': 'Minuman',
      'stock': 30,
      'isInfiniteStock': false,
      'isBestSeller': true,
      'variants': [
        {
          'name': 'Suhu',
          'isRequired': true,
          'allowMultiple': false,
          'priceType': 'Ganti Harga Utama',
          'options': [
            {'name': 'Panas', 'price': 20000},
            {'name': 'Dingin', 'price': 22000},
          ],
        },
      ],
    },
    {
      'name': 'Roti Bakar Coklat',
      'price': 15000,
      'image': 'https://via.placeholder.com/150',
      'category': 'Makanan',
      'stock': 20,
      'isInfiniteStock': false,
      'appliedDiscount': {
        'name': 'Flash Sale',
        'type': 'Nominal (Rp)',
        'value': 2000,
      },
      'variants': [],
    },
    {
      'name': 'Kentang Goreng',
      'price': 12000,
      'image': 'https://via.placeholder.com/150',
      'category': 'Snack',
      'stock': 40,
      'isInfiniteStock': false,
      'isBestSeller': false,
      'variants': [
        {
          'name': 'Bumbu',
          'isRequired': false,
          'allowMultiple': true,
          'priceType': 'Tambah Harga',
          'options': [
            {'name': 'BBQ', 'price': 1000},
            {'name': 'Keju', 'price': 1000},
            {'name': 'Balado', 'price': 1000},
          ],
        },
      ],
    },
    {
      'name': 'Dimsum Ayam',
      'price': 15000,
      'image': 'https://via.placeholder.com/150',
      'category': 'Snack',
      'stock': 25,
      'isInfiniteStock': false,
      'variants': [],
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

  Widget _buildProductItem(Map<String, dynamic> product, NumberFormat fmt) {
    final int qty = _getProductQty(product['name']);
    final bool isSelected = qty > 0;
    final bool hasVariants =
        product['variants'] != null && product['variants'].isNotEmpty;

    return MyProductCard(
      product: product,
      isGridView: _isGridView,
      isSelected: isSelected,
      currencyFormat: fmt,
      quantity: qty,
      onTap: () {
        if (DateTime.now().difference(_lastButtonTap).inMilliseconds < 400)
          return;

        if (hasVariants) {
          _showVariantPicker(product);
        } else {
          _addToCart(product);
        }
      },
      onIncrement: () {
        if (hasVariants) {
          _showVariantPicker(product);
        } else {
          _addToCart(product);
        }
      },
      onDecrement: () {
        _decrementLegacy(product['name']);
      },
    );
  }

  void _addToCart(
    Map<String, dynamic> product, {
    List<Map<String, dynamic>>? selectedOptions,
    double? customPrice,
  }) {
    setState(() {
      _lastButtonTap = DateTime.now();
      String key = product['name'];
      if (selectedOptions != null && selectedOptions.isNotEmpty) {
        final variantNames = selectedOptions.map((o) => o['name']).join(',');
        key = '${product['name']}|$variantNames';
      }

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

  void _showVariantPicker(Map<String, dynamic> product) {
    // Initial required variants selections
    Map<String, dynamic> selectedOptionsMap = {};
    for (var v in product['variants']) {
      if (v['isRequired'] == true && v['allowMultiple'] == false) {
        selectedOptionsMap[v['name']] = v['options'][0];
      } else if (v['allowMultiple'] == true) {
        selectedOptionsMap[v['name']] = <Map<String, dynamic>>[];
      }
    }

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
        return StatefulBuilder(
          builder: (context, setModalState) {
            double currentPrice = (product['price'] as num).toDouble();
            List<Map<String, dynamic>> finalSelectedOptions = [];

            // Calculate Price
            selectedOptionsMap.forEach((vName, selection) {
              final variant = (product['variants'] as List).firstWhere(
                (v) => v['name'] == vName,
              );

              if (variant['allowMultiple'] == true) {
                final list = selection as List<Map<String, dynamic>>;
                for (var opt in list) {
                  finalSelectedOptions.add({
                    'variantName': vName,
                    'name': opt['name'],
                    'price': opt['price'],
                  });
                  if (variant['priceType'] == 'Tambah Harga') {
                    currentPrice += (opt['price'] as num);
                  }
                }
              } else if (selection != null) {
                finalSelectedOptions.add({
                  'variantName': vName,
                  'name': selection['name'],
                  'price': selection['price'],
                });
                if (variant['priceType'] == 'Tambah Harga') {
                  currentPrice += (selection['price'] as num);
                } else if (variant['priceType'] == 'Ganti Harga Utama') {
                  currentPrice = (selection['price'] as num).toDouble();
                }
              }
            });

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
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
                                fmt.format(currentPrice),
                                style: GoogleFonts.plusJakartaSans(
                                  color: Warna.Primary,
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

                  // Variants List
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: (product['variants'] as List).length,
                      itemBuilder: (context, index) {
                        final variant = product['variants'][index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  variant['name'],
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                if (variant['isRequired'])
                                  Text(
                                    ' (Wajib)',
                                    style: TextStyle(
                                      color: Colors.red[400],
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: (variant['options'] as List).map((
                                option,
                              ) {
                                bool isSelected = false;
                                if (variant['allowMultiple']) {
                                  isSelected =
                                      (selectedOptionsMap[variant['name']]
                                              as List)
                                          .contains(option);
                                } else {
                                  isSelected =
                                      selectedOptionsMap[variant['name']] ==
                                      option;
                                }

                                return BounceTapper(
                                  onTap: () {
                                    setModalState(() {
                                      if (variant['allowMultiple']) {
                                        final list =
                                            selectedOptionsMap[variant['name']]
                                                as List<Map<String, dynamic>>;
                                        if (isSelected) {
                                          list.remove(option);
                                        } else {
                                          list.add(option);
                                        }
                                      } else {
                                        selectedOptionsMap[variant['name']] =
                                            option;
                                      }
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Warna.Primary
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isSelected
                                            ? Warna.Primary
                                            : Colors.grey[300]!,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          option['name'],
                                          style: TextStyle(
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.black,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                        if (option['price'] > 0) ...[
                                          const SizedBox(width: 4),
                                          Text(
                                            variant['priceType'] ==
                                                    'Tambah Harga'
                                                ? '(+${option['price']})'
                                                : '(${option['price']})',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: isSelected
                                                  ? Colors.white70
                                                  : Colors.grey[500],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 20),
                          ],
                        );
                      },
                    ),
                  ),

                  // Footer ADD Button
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: myButtonPrimary(
                      onPressed: () {
                        // Validate required
                        for (var v in product['variants']) {
                          if (v['isRequired']) {
                            if (v['allowMultiple']) {
                              if ((selectedOptionsMap[v['name']] as List)
                                  .isEmpty) {
                                MySnackBar(
                                  context: context,
                                  text: 'Pilih ${v['name']} terlebih dahulu',
                                  status: ToastStatus.error,
                                );
                                return;
                              }
                            } else {
                              if (selectedOptionsMap[v['name']] == null) {
                                MySnackBar(
                                  context: context,
                                  text: 'Pilih ${v['name']} terlebih dahulu',
                                  status: ToastStatus.error,
                                );
                                return;
                              }
                            }
                          }
                        }

                        _addToCart(
                          product,
                          selectedOptions: finalSelectedOptions,
                          customPrice: currentPrice,
                        );
                        Navigator.pop(context);
                      },
                      backgroundColor: Warna.Primary,
                      foregroundColor: Colors.white,
                      child: Center(
                        child: Text(
                          'Tambah ke Keranjang - ${fmt.format(currentPrice)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
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
