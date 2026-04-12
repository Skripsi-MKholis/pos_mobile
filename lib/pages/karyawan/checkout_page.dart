import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_mobile/CONFIGURATION/CONFIGURATION.dart';
import 'package:tabler_icons/tabler_icons.dart';
import 'package:pos_mobile/COMPONENTS/Components.dart';

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  const CheckoutPage({super.key, required this.cartItems});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late List<Map<String, dynamic>> items;

  @override
  void initState() {
    super.initState();
    // Copy the items to allow local editing of quantities
    items = List<Map<String, dynamic>>.from(
      widget.cartItems.map((item) => Map<String, dynamic>.from(item)),
    );
  }

  double get totalPrice {
    return items.fold(
        0, (sum, item) => sum + ((item['totalPrice'] ?? item['price']) * item['qty']));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: 'Checkout', isCenter: true),
      body: items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(TablerIcons.shopping_cart_off,
                      size: 80, color: Colors.grey[400]),
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
                return _buildCartItem(
                  index: index,
                  name: item['name'],
                  price: (item['totalPrice'] ?? item['price']).toDouble(),
                  qty: item['qty'],
                  imageUrl: item['image'],
                  selectedOptions: item['selectedOptions'] as List<dynamic>?,
                );
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
                children: [
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
                        'Rp ${totalPrice.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
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
                      MySnackBar(
                        context: context,
                        text: 'Pembayaran Berhasil!',
                        status: ToastStatus.success,
                      );
                      Navigator.pop(context);
                    },
                    backgroundColor: Warna.Primary,
                    foregroundColor: Colors.white,
                    child: const Text(
                      'Bayar Sekarang',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCartItem({
    required int index,
    required String name,
    required double price,
    required int qty,
    required String imageUrl,
    List<dynamic>? selectedOptions,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 70,
                height: 70,
                color: Colors.grey[200],
                child: const Icon(Icons.image, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (selectedOptions != null && selectedOptions.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    selectedOptions.map((o) => o['name']).join(', '),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 5),
                Text(
                  'Rp ${price.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: Warna.Primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _buildQtyButton(TablerIcons.minus, () {
                setState(() {
                  if (items[index]['qty'] > 1) {
                    items[index]['qty']--;
                  } else {
                    items.removeAt(index);
                  }
                });
              }),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  qty.toString(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
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
          ),
        ],
      ),
    );
  }

  Widget _buildQtyButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Warna.Primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: Warna.Primary),
      ),
    );
  }
}
