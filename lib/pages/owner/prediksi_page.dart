import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_mobile/configuration/configuration.dart';
import 'package:tabler_icons/tabler_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pos_mobile/components/components.dart';
import 'package:intl/intl.dart';

class PrediksiPage extends StatefulWidget {
  const PrediksiPage({super.key});

  @override
  State<PrediksiPage> createState() => _PrediksiPageState();
}

class _PrediksiPageState extends State<PrediksiPage> {
  String _selectedFilter = 'Mingguan';
  final List<String> _filters = ['Harian', 'Mingguan', 'Bulanan'];

  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Warna.bg,
      appBar: MyAppBar(title: 'Prediksi Penjualan', isCenter: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Filter Selector
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: _filters.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedFilter = filter),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? Warna.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        filter,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          color: isSelected ? Colors.white : Colors.grey,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // Revenue Prediction Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Warna.primary, Warna.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Warna.primary.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Estimasi Pendapatan',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                      ),
                    ),
                    const Icon(TablerIcons.trending_up, color: Colors.white),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _selectedFilter == 'Harian'
                      ? 'Rp 850.000'
                      : _selectedFilter == 'Mingguan'
                      ? 'Rp 5.950.000'
                      : 'Rp 24.500.000',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '+12% dari periode sebelumnya',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Prediction Chart
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
                  'Grafik Prediksi Permintaan',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 1,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.grey[200]!,
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const labels = [
                                'P1',
                                'P2',
                                'P3',
                                'P4',
                                'P5',
                                'P6',
                                'P7',
                              ];
                              if (value.toInt() >= 0 && value.toInt() < 7) {
                                return Text(
                                  labels[value.toInt()],
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
                          spots: [
                            const FlSpot(0, 2),
                            const FlSpot(1, 1.5),
                            const FlSpot(2, 3),
                            const FlSpot(3, 2.5),
                            const FlSpot(4, 4),
                            const FlSpot(5, 3.5),
                            const FlSpot(6, 5),
                          ],
                          isCurved: true,
                          color: Warna.primary,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Warna.primary.withValues(alpha: 0.05),
                          ),
                        ),
                        LineChartBarData(
                          spots: [
                            const FlSpot(0, 1),
                            const FlSpot(1, 2),
                            const FlSpot(2, 1.5),
                            const FlSpot(3, 3),
                            const FlSpot(4, 2),
                            const FlSpot(5, 4),
                            const FlSpot(6, 3),
                          ],
                          isCurved: true,
                          color: Colors.grey[300]!,
                          barWidth: 2,
                          dashArray: [5, 5],
                          dotData: FlDotData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegend(Warna.primary, 'Prediksi'),
                    const SizedBox(width: 16),
                    _buildLegend(Colors.grey[300]!, 'Aktual Rata-rata'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Smart Insight Sections
          Text(
            'Rekomendasi Restock',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          _buildRestockItem(
            'Biji Kopi Arabika',
            'Saran: Stok 5 Kg',
            'Kritis: Stok sisa 0.5 Kg',
            Colors.red,
          ),
          _buildRestockItem(
            'Susu UHT Full Cream',
            'Saran: Stok 12 Liter',
            'Aman untuk 2 hari kedepan',
            Colors.orange,
          ),
          _buildRestockItem(
            'Gula Aren Cair',
            'Saran: Stok 2 Liter',
            'Stok masih mencukupi',
            Colors.green,
          ),

          const SizedBox(height: 24),
          // Strategy Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(TablerIcons.bulb, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Saran Strategi',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.blue[800],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Berdasarkan prediksi, permintaan Kopi Susu Gula Aren akan meningkat drastis di akhir pekan. Pastikan stok Biji Kopi dan Susu UHT tersedia lebih awal.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: Colors.blue[900],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildRestockItem(
    String name,
    String suggestion,
    String desc,
    Color statusColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(TablerIcons.package, color: statusColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  suggestion,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: Warna.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  desc,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const Icon(TablerIcons.chevron_right, color: Colors.grey, size: 18),
        ],
      ),
    );
  }
}
