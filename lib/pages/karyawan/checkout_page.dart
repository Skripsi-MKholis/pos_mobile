import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tabler_icons/tabler_icons.dart';
import 'package:pos_mobile/repositories/master_repository.dart';
import 'package:pos_mobile/repositories/transaction_repository.dart';
import 'package:pos_mobile/models/transaction_model.dart';
import 'package:pos_mobile/models/transaction_item_model.dart';
import 'package:pos_mobile/models/customer_model.dart';
import 'package:pos_mobile/repositories/customer_repository.dart';
import 'package:uuid/uuid.dart';
import 'package:pos_mobile/pages/karyawan/struk_page.dart';
import 'package:pos_mobile/components/components.dart';
import 'package:pos_mobile/configuration/configuration.dart';
import 'package:pos_mobile/providers/auth_provider.dart';

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
  CustomerModel? selectedCustomer;
  List<Map<String, dynamic>> _allTables = [];
  List<CustomerModel> _allCustomers = [];
  bool _isLoadingTables = true;
  bool _isLoadingCustomers = true;

  @override
  void initState() {
    super.initState();
    // Copy the items to allow local editing of quantities
    items = List<Map<String, dynamic>>.from(
      widget.cartItems.map((item) => Map<String, dynamic>.from(item)),
    );
    _loadTables();
    _loadCustomers();
  }

  Future<void> _loadTables() async {
    setState(() => _isLoadingTables = true);
    try {
      final auth = context.read<AuthProvider>();
      final storeId = auth.selectedStore?.id;

      if (storeId == null) {
        if (mounted) setState(() => _isLoadingTables = false);
        return;
      }

      final masterRepo = context.read<MasterRepository>();
      final tables = await masterRepo.getTables(storeId);
      if (mounted) {
        setState(() {
          _allTables = tables;
          _isLoadingTables = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingTables = false);
      }
    }
  }

  Future<void> _loadCustomers() async {
    setState(() => _isLoadingCustomers = true);
    try {
      final auth = context.read<AuthProvider>();
      final storeId = auth.selectedStore?.id;

      if (storeId == null) {
        if (mounted) setState(() => _isLoadingCustomers = false);
        return;
      }

      final customerRepo = context.read<CustomerRepository>();
      final customers = await customerRepo.getCustomers(storeId);
      if (mounted) {
        setState(() {
          _allCustomers = customers;
          _isLoadingCustomers = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingCustomers = false);
      }
    }
  }

  @override
  void dispose() {
    orderNoteController.dispose();
    super.dispose();
  }

  void _showCustomerSelectionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pilih Pelanggan',
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
              if (_isLoadingCustomers)
                const Center(child: CircularProgressIndicator())
              else if (_allCustomers.isEmpty)
                Center(
                  child: Column(
                    children: [
                      const Icon(TablerIcons.users, size: 48, color: Colors.grey),
                      const SizedBox(height: 12),
                      Text(
                        'Belum ada data pelanggan',
                        style: GoogleFonts.plusJakartaSans(color: Colors.grey),
                      ),
                      TextButton(
                        onPressed: () => _loadCustomers(),
                        child: const Text('Refresh'),
                      ),
                    ],
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: _allCustomers.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.grey,
                            child: Icon(TablerIcons.user_minus, color: Colors.white),
                          ),
                          title: const Text('Tanpa Pelanggan'),
                          selected: selectedCustomer == null,
                          onTap: () {
                            setState(() => selectedCustomer = null);
                            Navigator.pop(context);
                          },
                        );
                      }
                      final customer = _allCustomers[index - 1];
                      final isSelected = selectedCustomer?.id == customer.id;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Warna.primary.withValues(alpha: 0.1),
                          child: Text(
                            customer.name[0].toUpperCase(),
                            style: TextStyle(color: Warna.primary, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(customer.name),
                        subtitle: Text(customer.phone ?? customer.email ?? '-'),
                        selected: isSelected,
                        onTap: () {
                          setState(() => selectedCustomer = customer);
                          Navigator.pop(context);
                        },
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
              _isLoadingTables
                  ? const Center(child: CircularProgressIndicator())
                  : _allTables.isEmpty
                      ? const Center(child: Text('Tidak ada meja tersedia'))
                      : GridView.builder(
                          shrinkWrap: true,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1.2,
                          ),
                          itemCount: _allTables.length,
                          itemBuilder: (context, index) {
                            final table = _allTables[index];
                            final isSelected =
                                selectedTable?['id'] == table['id'];
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
                                      ? Warna.primary
                                      : isOccupied
                                          ? Colors.grey[200]
                                          : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? Warna.primary
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
                                      isOccupied
                                          ? 'Terisi'
                                          : '${table['capacity']} Kursi',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10,
                                        color: isSelected
                                            ? Colors.white.withValues(
                                                alpha: 0.8)
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
                MyButtonPrimary(
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
                    color: Colors.grey.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Customer Selection
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pelanggan',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _showCustomerSelectionModal,
                        icon: const Icon(TablerIcons.user, size: 18),
                        label: Text(
                          selectedCustomer != null
                              ? selectedCustomer!.name
                              : 'Pilih Pelanggan',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            color: Warna.primary,
                          ),
                        ),
                      ),
                    ],
                  ),

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
                            color: Warna.primary,
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
                          color: Warna.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  MyButtonPrimary(
                    onPressed: () async {
                      if (selectedTable == null) {
                        mySnackBar(
                          context: context,
                          text: 'Mohon pilih meja terlebih dahulu!',
                          status: ToastStatus.warning,
                        );
                        return;
                      }

                      // Create Transaction Model
                      final transactionId = const Uuid().v4();
                      final auth = context.read<AuthProvider>();
                      final storeId = auth.selectedStore?.id;
                      final cashierId = auth.user?.id ?? '';

                      if (storeId == null) {
                        mySnackBar(
                          context: context,
                          text: 'Toko belum terpilih. Silakan login ulang.',
                          status: ToastStatus.error,
                        );
                        return;
                      }

                      final transactionItems = items.map((item) {
                        final unitPrice =
                            (item['totalPrice'] ?? item['price']).toDouble();
                        final subtotal = unitPrice * item['qty'];

                        return TransactionItemModel(
                          id: const Uuid().v4(),
                          transactionId: transactionId,
                          productId: item['id'],
                          productName: item['name'],
                          quantity: item['qty'],
                          unitPrice: unitPrice,
                          subtotal: subtotal,
                          notes: item['note'],
                        );
                      }).toList();

                      final transaction = TransactionModel(
                        localId: transactionId,
                        storeId: storeId,
                        cashierId: cashierId,
                        tableId: selectedTable!['id'],
                        customerId: selectedCustomer?.id, // Added customerId
                        items: transactionItems,
                        totalAmount: totalPrice,
                        paymentMethod: 'Tunai', // Default
                        createdAt: DateTime.now(),
                        notes: orderNoteController.text,
                      );

                      try {
                        final txRepo = context.read<TransactionRepository>();
                        await txRepo.saveTransaction(transaction);

                        if (!context.mounted) return;
                        mySnackBar(
                          context: context,
                          text:
                              'Pembayaran Berhasil untuk ${selectedTable!['name']}!',
                          status: ToastStatus.success,
                        );

                        // Navigate to Receipt (Struk) Page
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                StrukPage(transaction: transaction),
                          ),
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        mySnackBar(
                          context: context,
                          text: 'Gagal memproses transaksi: $e',
                          status: ToastStatus.error,
                        );
                      }
                    },
                    backgroundColor: Warna.primary,
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
                            ? Warna.primary
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
                        color: Warna.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Warna.primary.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            TablerIcons.info_circle,
                            size: 14,
                            color: Warna.primary,
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
                            color: Warna.primary,
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
              : Warna.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isNegative ? Colors.red : Warna.primary,
        ),
      ),
    );
  }
}
