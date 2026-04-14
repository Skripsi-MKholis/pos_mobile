import 'package:bounce_tapper/bounce_tapper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_mobile/CONFIGURATION/CONFIGURATION.dart';
import 'package:tabler_icons/tabler_icons.dart';
import 'package:pos_mobile/COMPONENTS/Components.dart';
import 'package:intl/intl.dart';

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  const CheckoutPage({super.key, required this.cartItems});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late List<Map<String, dynamic>> items;
  final TextEditingController orderNoteController = TextEditingController();
  Map<String, dynamic>? selectedTable;

  // Dummy Tables (In sync with ManageTablesPage for demo)
  final List<Map<String, dynamic>> tables = [
    {'id': '1', 'name': 'Meja 01', 'capacity': 2, 'status': 'Tersedia', 'area': 'Indoor'},
    {'id': '2', 'name': 'Meja 02', 'capacity': 4, 'status': 'Terisi', 'area': 'Indoor'},
    {'id': '3', 'name': 'Meja 03', 'capacity': 4, 'status': 'Tersedia', 'area': 'Outdoor'},
    {'id': '4', 'name': 'Meja 04', 'capacity': 6, 'status': 'Tersedia', 'area': 'Outdoor'},
    {'id': '5', 'name': 'VIP 01', 'capacity': 8, 'status': 'Tersedia', 'area': 'VIP Room'},
  ];

  @override
  void initState() {
    super.initState();
    // Copy the items to allow local editing of quantities
    items = List<Map<String, dynamic>>.from(
      widget.cartItems.map((item) => Map<String, dynamic>.from(item)),
    );
  }

  @override
  void dispose() {
    orderNoteController.dispose();
    super.dispose();
  }

  void _showTableSelectionModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pilih Meja / Seat',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(TablerIcons.x),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Flexible(
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: tables.length,
                  itemBuilder: (context, index) {
                    final table = tables[index];
                    final isSelected = selectedTable?['id'] == table['id'];
                    final isOccupied = table['status'] == 'Terisi';

                    return BounceTapper(
                      onTap: isOccupied
                          ? null
                          : () {
                              setState(() {
                                selectedTable = table;
                              });
                              Navigator.pop(context);
                            },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Warna.Primary
                              : isOccupied
                                  ? Colors.grey[200]
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? Warna.Primary
                                : isOccupied
                                    ? Colors.transparent
                                    : Colors.grey[300]!,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              table['name'],
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : isOccupied
                                        ? Colors.grey[500]
                                        : Colors.black,
                              ),
                            ),
                            Text(
                              isOccupied ? 'Terisi' : '${table['capacity']} Kursi',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                color: isSelected
                                    ? Colors.white.withOpacity(0.8)
                                    : isOccupied
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditItemNoteModal(int index) {
    final TextEditingController noteController = TextEditingController(
      text: items[index]['note'] ?? '',
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
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Edit Catatan Item',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(TablerIcons.x),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  items[index]['name'],
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 12),
                myTextField(
                  controller: noteController,
                  placeholder: 'Contoh: Tambah es, jangan pedas, dll.',
                ),
                const SizedBox(height: 20),
                myButtonPrimary(
                  onPressed: () {
                    setState(() {
                      items[index]['note'] = noteController.text;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Simpan Perubahan'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  double get totalPrice {
    return items.fold(
      0,
      (sum, item) => sum + (item['totalPrice'] * item['qty']),
    );
  }

  final NumberFormat _fmt = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: 'Checkout', isCenter: true),
      body: items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    TablerIcons.shopping_cart_off,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Keranjang Kosong',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return _buildCartItem(index: index, item: item);
              },
            ),
      bottomNavigationBar: items.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Table Selection
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pilihan Meja',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _showTableSelectionModal,
                        icon: const Icon(TablerIcons.armchair, size: 18),
                        label: Text(
                          selectedTable != null
                              ? selectedTable!['name']
                              : 'Pilih Meja',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            color: Warna.Primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Text(
                    'Catatan Pesanan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  myTextField(
                    controller: orderNoteController,
                    placeholder: 'Keterangan tambahan (Nama Pelanggan, dll)',
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Pembayaran',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                      Text(
                        _fmt.format(totalPrice),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Warna.Primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  myButtonPrimary(
                    onPressed: () {
                      if (selectedTable == null) {
                        MySnackBar(
                          context: context,
                          text: 'Mohon pilih meja terlebih dahulu!',
                          status: ToastStatus.warning,
                        );
                        return;
                      }

                      MySnackBar(
                        context: context,
                        text: 'Pembayaran Berhasil untuk ${selectedTable!['name']}!',
                        status: ToastStatus.success,
                      );
                      Navigator.pop(context);
                    },
                    backgroundColor: Warna.Primary,
                    foregroundColor: Colors.white,
                    child: const Text(
                      'Bayar Sekarang',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCartItem({
    required int index,
    required Map<String, dynamic> item,
  }) {
    final String name = item['name'];
    final String? note = item['note'];
    final double totalPrice = (item['totalPrice'] ?? item['price']).toDouble();
    final double originalPrice = (item['price'] ?? 0).toDouble();
    final int qty = item['qty'];
    final String imageUrl = item['image'];
    final List<dynamic>? selectedOptions =
        item['selectedOptions'] as List<dynamic>?;
    final Map<String, dynamic>? discount =
        item['appliedDiscount'] as Map<String, dynamic>?;
    final int? stock = item['stock'] as int?;
    final bool isInfiniteStock = item['isInfiniteStock'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyNetworkImage(
            imageUrl: imageUrl,
            width: 80,
            height: 80,
            borderRadius: 12,
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
                        name,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    BounceTapper(
                      onTap: () => _showEditItemNoteModal(index),
                      child: Icon(
                        TablerIcons.note,
                        size: 18,
                        color: note != null && note.isNotEmpty
                            ? Warna.Primary
                            : Colors.grey[400],
                      ),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: (stock ?? 0) > 0 || isInfiniteStock
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isInfiniteStock ? 'Stok: ∞' : 'Stok: $stock',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: (stock ?? 0) > 0 || isInfiniteStock
                              ? Colors.green[700]
                              : Colors.red[700],
                        ),
                      ),
                    ),
                    if (selectedOptions != null && selectedOptions.isNotEmpty)
                      ...selectedOptions.map((o) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            o['name'],
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        );
                      }),
                  ],
                ),
                if (note != null && note.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  BounceTapper(
                    onTap: () => _showEditItemNoteModal(index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Warna.Primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Warna.Primary.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            TablerIcons.info_circle,
                            size: 14,
                            color: Warna.Primary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              note,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: Colors.grey[700],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (discount != null)
                          Text(
                            _fmt.format(originalPrice),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: Colors.grey[400],
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        Text(
                          _fmt.format(totalPrice),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            color: Warna.Primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    _buildQuantityControl(index, qty),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityControl(int index, int qty) {
    return Row(
      children: [
        _buildQtyButton(TablerIcons.minus, () {
          setState(() {
            if (items[index]['qty'] > 1) {
              items[index]['qty']--;
            } else {
              items.removeAt(index);
            }
          });
        }, isNegative: true),
        Container(
          constraints: const BoxConstraints(minWidth: 30),
          alignment: Alignment.center,
          child: Text(
            qty.toString(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _buildQtyButton(TablerIcons.plus, () {
          setState(() {
            items[index]['qty']++;
          });
        }),
      ],
    );
  }

  Widget _buildQtyButton(
    IconData icon,
    VoidCallback onTap, {
    bool isNegative = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isNegative
              ? Colors.red.withValues(alpha: 0.1)
              : Warna.Primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isNegative ? Colors.red : Warna.Primary,
        ),
      ),
    );
  }
}
