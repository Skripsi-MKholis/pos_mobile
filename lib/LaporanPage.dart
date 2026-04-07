import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_mobile/CONFIGURATION/CONFIGURATION.dart';
import 'package:tabler_icons/tabler_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:bounce_tapper/bounce_tapper.dart';

class LaporanPage extends StatelessWidget {
  const LaporanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(5),
        child: ListView(
          children: [
            const SizedBox(height: 5),
            _buildStatisticsCard(),
            _buildPieChartCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard() {
    // Dummy data for Sales
    final int totalTransaksi = 150;
    final int transaksiBerhasil = 145;
    final int transaksiBatal = 5;

    return Container(
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(TablerIcons.graph, color: Warna.Primary, size: 20),
              SizedBox(width: 10),
              Text(
                'Statistik Penjualan',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Divider(color: Warna.Primary.withOpacity(0.2)),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatBox('Total', totalTransaksi, Colors.blue),
              _buildStatBox('Berhasil', transaksiBerhasil, Colors.green),
              _buildStatBox('Batal', transaksiBatal, Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String title, int value, Color color) {
    return BounceTapper(
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              value.toString(),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChartCard() {
    final int makanan = 45;
    final int minuman = 30;
    final int snack = 25;

    return Container(
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(TablerIcons.chart_pie, color: Warna.Primary, size: 20),
              SizedBox(width: 10),
              Text(
                'Distribusi Kategori Terjual',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Divider(color: Warna.Primary.withOpacity(0.2)),
          const SizedBox(height: 15),
          AspectRatio(
            aspectRatio: 16 / 9,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: makanan.toDouble(),
                    borderSide: BorderSide(color: Colors.orange, width: 2),
                    color: Colors.orange.withOpacity(0.1),
                    title: 'Makanan\n$makanan%',
                    radius: 60,
                    titleStyle: const TextStyle(
                      color: Colors.orange,
                      fontSize: 12,
                    ),
                  ),
                  PieChartSectionData(
                    value: minuman.toDouble(),
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                    color: Colors.blue.withOpacity(0.1),
                    title: 'Minuman\n$minuman%',
                    radius: 60,
                    titleStyle: const TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                    ),
                  ),
                  PieChartSectionData(
                    value: snack.toDouble(),
                    borderSide: BorderSide(color: Colors.green, width: 2),
                    color: Colors.green.withOpacity(0.1),
                    title: 'Snack\n$snack%',
                    radius: 60,
                    titleStyle: const TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                    ),
                  ),
                ],
                sectionsSpace: 4,
                centerSpaceRadius: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
