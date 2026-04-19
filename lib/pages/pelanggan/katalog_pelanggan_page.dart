import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_mobile/configuration/configuration.dart';
import 'package:tabler_icons/tabler_icons.dart';
import 'package:pos_mobile/components/components.dart';
import 'package:pos_mobile/components/product_card.dart';
import 'package:pos_mobile/pages/pelanggan/keranjang_page.dart';
import 'package:intl/intl.dart';

class KatalogPelangganPage extends StatefulWidget {
  final String mejaInfo;

  const KatalogPelangganPage({super.key, required this.mejaInfo});

  @override
  State<KatalogPelangganPage> createState() => _KatalogPelangganPageState();
}

class _KatalogPelangganPageState extends State<KatalogPelangganPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isGridView = true;

  String _selectedCategory = 'Semua';
  String _searchQuery = '';
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
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Menu Pesanan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.mejaInfo,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: Warna.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: () {
                  _goToCart();
                },
                icon: const Icon(TablerIcons.shopping_cart),
              ),
              if (totalItems > 0)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      totalItems.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
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
                    placeholder: 'Cari makanan atau minuman...',
                  ),
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
          if (products.isEmpty)
            _buildEmpty()
          else if (filteredProducts.isEmpty)
            _buildEmpty()
          else
            _buildProductGrid(),
        ],
      ),
      floatingActionButton: totalItems > 0
          ? FloatingActionButton.extended(
              heroTag: 'cartBtn',
              onPressed: () {
                _goToCart();
              },
              backgroundColor: Warna.primary,
              icon: const Icon(
                TablerIcons.shopping_cart,
                color: Colors.white,
              ),
              label: Text(
                'Lihat Keranjang ($totalItems)',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            )
          : null,
    );
  }

  void _goToCart() {
    List<Map<String, dynamic>> selectedItems = [];
    _cart.forEach((key, item) {
      selectedItems.add(Map<String, dynamic>.from(item));
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            KeranjangPage(cartItems: selectedItems, mejaInfo: widget.mejaInfo),
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
        if (DateTime.now().difference(_lastButtonTap).inMilliseconds < 400) {
          return;
        }

        if (hasVariants) {
          _showVariantPicker(product);
        } else {
          _showProductNoteModal(product);
        }
      },
      onIncrement: () {
        if (hasVariants) {
          _showVariantPicker(product);
        } else {
          _showProductNoteModal(product);
        }
      },
      onDecrement: () {
        _decrementLegacy(product['name']);
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
                        'Tambah ke Pesanan',
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

      String key = '${product['name']}|$variantNames|${note ?? ''}';

      if (_cart.containsKey(key)) {
        _cart[key]!['qty']++;
      } else {
        _cart[key] = {
          'name': product['name'],
          'price': product['price'], // Original price
          'totalPrice': customPrice ?? product['price'], // Final price after adjustments
          'image': product['image'],
          'qty': 1,
          'selectedOptions': selectedOptions ?? [],
          'note': note ?? '',
          'appliedDiscount': product['appliedDiscount'],
        };
      }
    });
  }

  void _decrementLegacy(String productName) {
    setState(() {
      _lastButtonTap = DateTime.now();
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
    final TextEditingController noteController = TextEditingController();
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
              if (vName == '__note__') return;
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

                  // Variants List & Note
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        ...(product['variants'] as List).map((variant) {
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
                                            ? Warna.primary
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: isSelected
                                              ? Warna.primary
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
                        }),

                        const SizedBox(height: 10),
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
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),

                  // Footer ADD Button
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: MyButtonPrimary(
                      onPressed: () {
                        // Validate required
                        for (var v in product['variants']) {
                          if (v['isRequired']) {
                            if (v['allowMultiple']) {
                              if ((selectedOptionsMap[v['name']] as List)
                                  .isEmpty) {
                                mySnackBar(
                                  context: context,
                                  text: 'Pilih ${v['name']} terlebih dahulu',
                                  status: ToastStatus.error,
                                );
                                return;
                              }
                            } else {
                              if (selectedOptionsMap[v['name']] == null) {
                                mySnackBar(
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
                          note: noteController.text,
                        );
                        Navigator.pop(context);
                      },
                      backgroundColor: Warna.primary,
                      foregroundColor: Colors.white,
                      child: Center(
                        child: Text(
                          'Tambah ke Pesanan - ${fmt.format(currentPrice)}',
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
}
