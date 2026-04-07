import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_mobile/CONFIGURATION/CONFIGURATION.dart';
import 'package:tabler_icons/tabler_icons.dart';
import 'package:pos_mobile/COMPONENTS/Components.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          _buildCartItem(
            name: 'Kopi Susu Gula Aren',
            price: 18000,
            qty: 2,
            imageUrl: 'https://via.placeholder.com/150',
          ),
          _buildCartItem(
            name: 'Roti Bakar Coklat',
            price: 15000,
            qty: 1,
            imageUrl: 'https://via.placeholder.com/150',
          ),
          _buildCartItem(
            name: 'Kentang Goreng',
            price: 12000,
            qty: 1,
            imageUrl: 'https://via.placeholder.com/150',
          ),
        ],
      ),
      bottomNavigationBar: Container(
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
                  'Rp 63.000',
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
              },
              backgroundColor: Warna.Primary,
              foregroundColor: Colors.white,
              child: const Text(
                'Bayar Sekarang',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem({
    required String name,
    required double price,
    required int qty,
    required String imageUrl,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
                ),
                const SizedBox(height: 5),
                Text(
                  'Rp ${price.toInt()}',
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
              _buildQtyButton(TablerIcons.minus, () {}),
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
              _buildQtyButton(TablerIcons.plus, () {}),
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
