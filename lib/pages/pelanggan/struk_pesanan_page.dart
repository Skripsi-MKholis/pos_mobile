import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_mobile/configuration/configuration.dart';
import 'package:dotted_dashed_line/dotted_dashed_line.dart';
import 'package:tabler_icons/tabler_icons.dart';
import 'package:pos_mobile/components/components.dart';
import 'package:intl/intl.dart';

class StrukPesananPage extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final String mejaInfo;

  const StrukPesananPage({
    super.key,
    required this.items,
    required this.mejaInfo,
  });

  double get total {
    double t = 0;
    for (var item in items) {
      t += (item['totalPrice'] as num) * (item['qty'] as int);
    }
    return t;
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Struk Pesanan',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header Struk
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(TablerIcons.receipt, size: 48, color: Warna.primary),
                    const SizedBox(height: 16),
                    Text(
                      'Toko Berkah Jaya',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Jl. Sudirman No. 123, Jakarta',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tanggal',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[500],
                              ),
                            ),
                            Text(
                              DateFormat(
                                'dd MMM yyyy, HH:mm',
                              ).format(DateTime.now()),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Meja',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[500],
                              ),
                            ),
                            Text(
                              mejaInfo,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              DottedDashedLine(
                height: 0,
                width: double.infinity,
                axis: Axis.horizontal,
                dashColor: Colors.grey[300]!,
              ),

              // Daftar Item
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: items.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${item['qty']}x',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['name'],
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                if (item['selectedOptions'] != null &&
                                    (item['selectedOptions'] as List).isNotEmpty)
                                  Text(
                                    (item['selectedOptions'] as List)
                                        .map((e) => e['name'])
                                        .join(', '),
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Text(
                            fmt.format(item['totalPrice'] * item['qty']),
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              DottedDashedLine(
                height: 0,
                width: double.infinity,
                axis: Axis.horizontal,
                dashColor: Colors.grey[300]!,
              ),

              // Total
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Pembayaran',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      fmt.format(total),
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Warna.primary,
                      ),
                    ),
                  ],
                ),
              ),

              // Instruksi Pembayaran
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Warna.primary.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Silakan tunjukkan struk ini di kasir untuk melakukan pembayaran.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        color: Warna.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: MyButtonPrimary(
            onPressed: () {
              // Kembali ke Beranda atau Dashboard utama Pelanggan
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            backgroundColor: Warna.primary,
            foregroundColor: Colors.white,
            child: const Center(
              child: Text(
                'Selesai & Kembali ke Beranda',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
