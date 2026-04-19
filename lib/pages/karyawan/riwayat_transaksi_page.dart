import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_mobile/components/components.dart';
import 'package:pos_mobile/configuration/configuration.dart';
import 'package:tabler_icons/tabler_icons.dart';
import 'package:provider/provider.dart';
import 'package:pos_mobile/repositories/transaction_repository.dart';
import 'package:intl/intl.dart';
import 'package:pos_mobile/providers/auth_provider.dart';

class RiwayatTransaksiPage extends StatefulWidget {
  final String? customerId;
  final String? customerName;
  const RiwayatTransaksiPage({super.key, this.customerId, this.customerName});

  @override
  State<RiwayatTransaksiPage> createState() => _RiwayatTransaksiPageState();
}

class _RiwayatTransaksiPageState extends State<RiwayatTransaksiPage> {
  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  bool _isLoading = true;
  List<Map<String, dynamic>> _transactions = [];

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    setState(() => _isLoading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final storeId = auth.selectedStore?.id;

    if (storeId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final trxRepo = Provider.of<TransactionRepository>(context, listen: false);
    
    try {
      var results = await trxRepo.getTransactions(storeId);
      
      // Apply customer filter if provided
      if (widget.customerId != null) {
        results = results.where((t) => t.customerId == widget.customerId).toList();
      }

      if (mounted) {
        setState(() {
          _transactions = results.map((t) => t.toMap()).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat transaksi: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Warna.bg,
      appBar: MyAppBar(
        title: widget.customerName != null 
            ? 'Transaksi: ${widget.customerName}' 
            : 'Riwayat Transaksi', 
        isCenter: false,
      ),
      body: SafeArea(
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Warna.primary))
          : RefreshIndicator(
              onRefresh: _fetchTransactions,
              color: Warna.primary,
              child: _transactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(TablerIcons.receipt_off, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada transaksi',
                          style: GoogleFonts.plusJakartaSans(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _transactions.length,
                    itemBuilder: (context, index) {
                      final trx = _transactions[index];
                      return _buildTransactionItem(trx);
                    },
                  ),
            ),
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> trx) {
    final createdAt = DateTime.parse(trx['created_at']);
    final isSynced = trx['synced'] == 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Warna.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(TablerIcons.receipt_2, color: Warna.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trx['id'].substring(0, 8).toUpperCase(),
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd MMM yyyy, HH:mm').format(createdAt),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currencyFormat.format(trx['total_revenue'] ?? trx['total_amount'] ?? 0),
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Warna.primary,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isSynced 
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isSynced) ...[
                      const Icon(TablerIcons.cloud_off, size: 10, color: Colors.orange),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      isSynced ? 'Selesai' : 'Pending',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isSynced ? Colors.green : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
