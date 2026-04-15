import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_mobile/configuration/configuration.dart';
import 'package:tabler_icons/tabler_icons.dart';
import 'package:pos_mobile/components/components.dart';
import 'package:pos_mobile/pages/pelanggan/status_pesanan_page.dart';
import 'package:intl/intl.dart';

class KeranjangPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final String mejaInfo;

  const KeranjangPage({
    super.key,
    required this.cartItems,
    required this.mejaInfo,
  });

  @override
  State<KeranjangPage> createState() => _KeranjangPageState();
}

class _KeranjangPageState extends State<KeranjangPage> {
  final fmt = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  double get subtotal {
    double total = 0;
    for (var item in widget.cartItems) {
      total += (item['totalPrice'] as num) * (item['qty'] as int);
    }
    return total;
  }

  double get total {
    return subtotal; // Pajak/Layanan bisa ditambahkan di sini jika perlu
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Warna.bg,
      appBar: AppBar(
        title: Text(
          'Keranjang',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: widget.cartItems.isEmpty
          ? _buildEmptyCart()
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: widget.cartItems.length,
                    itemBuilder: (context, index) {
                      return _buildCartItem(widget.cartItems[index], index);
                    },
                  ),
                ),
                _buildSummarySection(),
              ],
            ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(TablerIcons.shopping_cart_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Keranjang Kosong',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Silakan tambahkan menu terlebih dahulu.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item, int index) {
    String variantsText = '';
    if (item['selectedOptions'] != null) {
      final opts = item['selectedOptions'] as List;
      if (opts.isNotEmpty) {
        variantsText = opts.map((e) => e['name']).join(', ');
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyNetworkImage(
            imageUrl: item['image'],
            width: 70,
            height: 70,
            borderRadius: 12,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item['name'],
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(TablerIcons.trash, color: Colors.red[400], size: 18),
                      onPressed: () {
                        setState(() {
                          widget.cartItems.removeAt(index);
                        });
                      },
                    ),
                  ],
                ),
                if (variantsText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      variantsText,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                if (item['note'] != null && item['note'].toString().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Catatan: ${item['note']}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      fmt.format(item['totalPrice']),
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        color: Warna.primary,
                        fontSize: 14,
                      ),
                    ),
                    Row(
                      children: [
                        _buildQtyBtn(TablerIcons.minus, () {
                          if (item['qty'] > 1) {
                            setState(() {
                              item['qty']--;
                            });
                          } else {
                            setState(() {
                              widget.cartItems.removeAt(index);
                            });
                          }
                        }),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            item['qty'].toString(),
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        _buildQtyBtn(TablerIcons.plus, () {
                          setState(() {
                            item['qty']++;
                          });
                        }),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Warna.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16, color: Warna.primary),
      ),
    );
  }

  Widget _buildSummarySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Pesanan',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                Text(
                  fmt.format(total),
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            MyButtonPrimary(
              onPressed: () {
                // Konfirmasi Pesanan dan Kirim ke Dapur
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Konfirmasi Pesanan'),
                    content: const Text('Kirim pesanan ke dapur sekarang?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Batal'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Close dialog

                          // Mock process to kitchen
                          mySnackBar(
                            context: context,
                            text: 'Pesanan berhasil dikirim ke dapur!',
                            status: ToastStatus.success,
                          );

                          // Navigate to Order Status Page removing the catalog and cart from stack
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StatusPesananPage(
                                items: widget.cartItems,
                                mejaInfo: widget.mejaInfo,
                              ),
                            ),
                            (route) => route.isFirst,
                          );
                        },
                        child: const Text('Kirim'),
                      ),
                    ],
                  ),
                );
              },
              backgroundColor: Warna.primary,
              foregroundColor: Colors.white,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(TablerIcons.send, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Pesan Sekarang',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
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
