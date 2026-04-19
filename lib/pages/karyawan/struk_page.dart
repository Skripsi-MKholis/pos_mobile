import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_mobile/configuration/configuration.dart';
import 'package:tabler_icons/tabler_icons.dart';
import 'package:pos_mobile/components/components.dart';
import 'package:intl/intl.dart';
import 'package:pos_mobile/models/transaction_model.dart';
import 'package:pos_mobile/utils/receipt_generator.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class StrukPage extends StatelessWidget {
  final TransactionModel transaction;

  const StrukPage({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: MyAppBar(
        title: 'Transaksi Berhasil',
        isCenter: true,
        actions: [
          IconButton(
            icon: const Icon(TablerIcons.share),
            onPressed: () => _shareReceipt(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildReceiptCard(fmt),
            const SizedBox(height: 24),
            _buildActionButtons(context),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: MyButtonPrimary(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            backgroundColor: Warna.primary,
            foregroundColor: Colors.white,
            child: const Text('Kembali ke Kasir'),
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptCard(NumberFormat fmt) {
    return Container(
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
          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(TablerIcons.circle_check_filled,
                    size: 64, color: Colors.green),
                const SizedBox(height: 16),
                Text(
                  'Pembayaran Berhasil',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  fmt.format(transaction.totalAmount),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Warna.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'ID: ${transaction.localId.substring(0, 8).toUpperCase()}',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          // Details
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildInfoRow('Waktu',
                    DateFormat('dd MMM yyyy, HH:mm').format(transaction.createdAt)),
                _buildInfoRow('Meja', transaction.tableId ?? '-'),
                _buildInfoRow('Metode', transaction.paymentMethod),
                const SizedBox(height: 12),
                const Divider(color: Colors.black12),
                const SizedBox(height: 12),
                ...transaction.items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${item.quantity}x ${item.productName}',
                              style: GoogleFonts.plusJakartaSans(fontSize: 13),
                            ),
                          ),
                          Text(
                            fmt.format(item.price * item.quantity),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.plusJakartaSans(
                  color: Colors.grey[600], fontSize: 13)),
          Text(value,
              style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        MyButtonPrimary(
          onPressed: () => _printReceipt(context),
          isOutlined: true,
          backgroundColor: Colors.white,
          foregroundColor: Warna.primary,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(TablerIcons.printer, size: 20),
              SizedBox(width: 8),
              Text('Cetak Struk (Thermal)'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        MyButtonPrimary(
          onPressed: () => _shareReceipt(context),
          isOutlined: true,
          backgroundColor: Colors.white,
          foregroundColor: Warna.primary,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(TablerIcons.brand_whatsapp, size: 20),
              SizedBox(width: 8),
              Text('Kirim ke WhatsApp'),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _printReceipt(BuildContext context) async {
    final pdfBytes = await ReceiptGenerator.generateReceipt(transaction);
    await Printing.layoutPdf(
      onLayout: (format) async => pdfBytes,
      name: 'Receipt_${transaction.localId.substring(0, 8)}',
    );
  }

  Future<void> _shareReceipt(BuildContext context) async {
    final pdfBytes = await ReceiptGenerator.generateReceipt(transaction);
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/struk_${transaction.localId.substring(0, 8)}.pdf');
    await file.writeAsBytes(pdfBytes);
    
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Berikut adalah struk pesanan Anda dari Toko Berkah Jaya.',
    );
  }
}
