import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_mobile/components/components.dart';
import 'package:pos_mobile/configuration/configuration.dart';
import 'package:tabler_icons/tabler_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:pos_mobile/repositories/transaction_repository.dart';
import 'package:pos_mobile/repositories/report_repository.dart';
import '../../providers/auth_provider.dart';

import 'package:intl/intl.dart';
import 'package:pos_mobile/pages/owner/prediksi_page.dart';

class LaporanPage extends StatefulWidget {
  const LaporanPage({super.key});

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  bool _isLoading = true;
  List<Map<String, dynamic>> _transactions = [];
  Map<String, dynamic>? _summary;
  List<Map<String, dynamic>> _weeklyTrend = [];
  List<Map<String, dynamic>> _topProducts = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final storeId = auth.selectedStore?.id;

    if (storeId == null) {
      setState(() => _isLoading = false);
      return;
    }

    final trxRepo = Provider.of<TransactionRepository>(context, listen: false);
    final reportRepo = Provider.of<ReportRepository>(context, listen: false);

    try {
      final transactions = await trxRepo.getTransactions(storeId);
      final summary = await reportRepo.getDailySummary(storeId);
      final trend = await reportRepo.getWeeklyTrend(storeId);
      final products = await reportRepo.getProductInsights(storeId);

      setState(() {
        _transactions = transactions.map((t) => t.toMap()).toList();
        _summary = summary;
        _weeklyTrend = trend;
        _topProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Warna.bg,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            color: Colors.white,
            child: TabBar(
              indicatorColor: Warna.primary,
              labelColor: Warna.primary,
              unselectedLabelColor: Colors.grey,
              labelStyle: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              tabs: const [
                Tab(text: 'Transaksi'),
                Tab(text: 'Laporan'),
                Tab(text: 'Kelola Pintar'),
              ],
            ),
          ),
        ),
        body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Warna.primary))
          : TabBarView(
              children: [
                _buildTransaksiTab(),
                _buildLaporanTab(),
                _buildKelolaPintarTab(),
              ],
            ),
      ),
    );
  }

  Widget _buildTransaksiTab() {
    if (_transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(TablerIcons.receipt_off, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('Belum ada transaksi', style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchData,
      color: Warna.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _transactions.length,
        itemBuilder: (context, index) {
          final trx = _transactions[index];
          final createdAt = DateTime.parse(trx['created_at']);

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    TablerIcons.check,
                    color: Colors.green,
                    size: 20,
                  ),
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
                        ),
                      ),
                      Text(
                        '${DateFormat('dd MMM yyyy').format(createdAt)} • ${DateFormat('HH:mm').format(createdAt)}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: Colors.grey,
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
                    Text(
                      trx['payment_method'] ?? 'Tunai',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLaporanTab() {
    final revenue = _summary?['total_revenue'] ?? 0;
    final transactions = _summary?['total_transactions'] ?? 0;
    
    return RefreshIndicator(
      onRefresh: _fetchData,
      color: Warna.primary,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary Cards Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildSummaryCard(
                'Total Penjualan',
                currencyFormat.format(revenue),
                TablerIcons.cash,
                Colors.blue,
              ),
              _buildSummaryCard(
                'Keuntungan Kotor',
                currencyFormat.format(revenue * 0.4), // Sample logic
                TablerIcons.chart_bar,
                Colors.orange,
              ),
              _buildSummaryCard(
                'Pengeluaran',
                'Rp 0',
                TablerIcons.receipt,
                Colors.red,
              ),
              _buildSummaryCard(
                'Transaksi',
                transactions.toString(),
                TablerIcons.shopping_cart,
                Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Chart Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Grafik Penjualan (7 Hari Terakhir)',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: _weeklyTrend.isEmpty 
                    ? const Center(child: Text('Belum ada data grafik'))
                    : LineChart(_chartData()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildDetailSummary('Keuntungan Bersih', currencyFormat.format(revenue * 0.4), Colors.green),
        ],
      ),
    );
  }

  LineChartData _chartData() {
    final spots = _weeklyTrend.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), (e.value['revenue'] as num).toDouble());
    }).toList();

    return LineChartData(
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              if (value.toInt() >= 0 && value.toInt() < _weeklyTrend.length) {
                final dateStr = _weeklyTrend[value.toInt()]['date'] as String;
                final date = DateTime.parse(dateStr);
                return Text(
                  DateFormat('E').format(date),
                  style: const TextStyle(fontSize: 10),
                );
              }
              return const Text('');
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: Warna.primary,
          barWidth: 3,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: Warna.primary.withValues(alpha: 0.1),
          ),
        ),
      ],
    );
  }

  Widget _buildKelolaPintarTab() {
    return RefreshIndicator(
      onRefresh: _fetchData,
      color: Warna.primary,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // AI Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Warna.primary, Warna.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(TablerIcons.sparkles, color: Colors.white, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Smart Insights',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        'Berdasarkan performa toko Anda',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Product Insights
          Text(
            'Produk Terlaris 🔥',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),
          if (_topProducts.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(child: Text('Data belum tersedia', style: TextStyle(color: Colors.grey[400]))),
            )
          else
            ..._topProducts.take(3).map((p) => _buildProductInsightItem(
              p['product_name'] ?? 'Produk', 
              '${p['quantity']} Terjual', 
              true
            )),
          
          const SizedBox(height: 20),
          Text(
            'Kurang Diminati 📉',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),
          _buildProductInsightItem('Produk Contoh', '0 Terjual', false),
          const SizedBox(height: 20),

          // Prediction Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Warna.primary.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Prediksi Restock',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Warna.bg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Mingguan',
                        style: TextStyle(fontSize: 10),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildRestockRow('Bahan Baku Utama', 'Secukupnya', 'Dalam 3 Hari'),
                const SizedBox(height: 20),
                MyButtonPrimary(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PrediksiPage(),
                      ),
                    );
                  },
                  backgroundColor: Warna.primary,
                  foregroundColor: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(TablerIcons.brain, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Lihat Detail Prediksi',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSummary(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductInsightItem(String name, String stat, bool isPositive) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 30,
            decoration: BoxDecoration(
              color: isPositive ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            stat,
            style: GoogleFonts.plusJakartaSans(
              color: isPositive ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestockRow(String item, String qty, String timeframe) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  'Saran: Stok $qty',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            timeframe,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
