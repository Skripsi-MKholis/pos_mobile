import 'package:bounce_tapper/bounce_tapper.dart';
import 'package:pos_mobile/CONFIGURATION/CONFIGURATION.dart';
import 'package:pos_mobile/KosongPage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget buildUserCard(
  BuildContext context,
  String userId,
  String fullName,
  String nomorInduk,
  String role,
  String label,
  String avatarUrl,
) {
  return BounceTapper(
    highlightColor: Colors.transparent,
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => role == 'dosen'
              ? KosongPage()
              : role == 'mahasiswa'
              ? const KosongPage()
              : const KosongPage(),
        ),
      );
    },
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Warna.Primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Warna.Primary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.all(8),
            child: CircleAvatar(
              radius: 18,
              foregroundImage: AssetImage(avatarUrl),
              backgroundColor: Colors.grey[300],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fullName,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: Warna.Primary,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                nomorInduk,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: Colors.black,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Warna.Primary,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Text(
              label.toUpperCase(),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 10),
        ],
      ),
    ),
  );
}

/* Dosen Rating */
class RatingBar extends StatelessWidget {
  final double averageRating; // nilai dari 1.0 sampai 5.0

  const RatingBar({super.key, required this.averageRating});

  @override
  Widget build(BuildContext context) {
    final percentage = (averageRating / 5.0) * 100;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Rating Dosen",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Divider(color: Warna.Line.withOpacity(0.3)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber),
              const SizedBox(width: 8),
              Text(
                "${averageRating.toStringAsFixed(1)} / 5.0",
                style: const TextStyle(fontSize: 16),
              ),
              const Spacer(),
              Text(
                "${percentage.toStringAsFixed(0)}%",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 14,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(Warna.Primary),
            ),
          ),
        ],
      ),
    );
  }
}

/* Dosen Rating */
