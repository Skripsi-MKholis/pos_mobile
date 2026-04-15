import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_mobile/configuration/configuration.dart';
import 'package:tabler_icons/tabler_icons.dart';
import 'package:pos_mobile/components/components.dart';
import 'package:pos_mobile/pages/pelanggan/struk_pesanan_page.dart';
import 'package:pos_mobile/pages/pelanggan/katalog_pelanggan_page.dart';
import 'package:intl/intl.dart';

class StatusPesananPage extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final String mejaInfo;

  const StatusPesananPage({
    super.key,
    required this.items,
    required this.mejaInfo,
  });

  @override
  State<StatusPesananPage> createState() => _StatusPesananPageState();
}

class _StatusPesananPageState extends State<StatusPesananPage> {
  final fmt = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Warna.bg,
      appBar: AppBar(
        title: Text(
          'Pesanan Saya',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(TablerIcons.arrow_left),
          onPressed: () {
            // Back to Beranda
            Navigator.pop(context);
          },
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Warna.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(TablerIcons.armchair, color: Warna.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status: Sedang Disiapkan',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            color: Warna.primary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pesanan Anda sedang diproses oleh dapur.',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return _buildOrderedItem(widget.items[index]);
                },
                childCount: widget.items.length,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: const SizedBox(height: 100), // padding bottom
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: MyButtonPrimary(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => KatalogPelangganPage(
                          mejaInfo: widget.mejaInfo,
                        ),
                      ),
                    );
                  },
                  backgroundColor: Colors.white,
                  foregroundColor: Warna.primary,
                  isOutlined: true,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(TablerIcons.plus, size: 18),
                        const SizedBox(width: 8),
                        Text('Tambah'),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MyButtonPrimary(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StrukPesananPage(
                          items: widget.items,
                          mejaInfo: widget.mejaInfo,
                        ),
                      ),
                    );
                  },
                  backgroundColor: Warna.primary,
                  foregroundColor: Colors.white,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(TablerIcons.receipt, size: 18, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          'Minta Bill',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderedItem(Map<String, dynamic> item) {
    String variantsText = '';
    if (item['selectedOptions'] != null) {
      final opts = item['selectedOptions'] as List;
      if (opts.isNotEmpty) {
        variantsText = opts.map((e) => e['name']).join(', ');
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${item['qty']}x',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
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
              ],
            ),
          ),
          Text(
            fmt.format(item['totalPrice'] * item['qty']),
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.bold,
              color: Warna.primary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
