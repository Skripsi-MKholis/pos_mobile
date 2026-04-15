import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_mobile/configuration/configuration.dart';
import 'package:pos_mobile/components/components.dart';
import 'package:pos_mobile/pages/pelanggan/katalog_pelanggan_page.dart';

class ScanMejaPage extends StatefulWidget {
  const ScanMejaPage({super.key});

  @override
  State<ScanMejaPage> createState() => _ScanMejaPageState();
}

class _ScanMejaPageState extends State<ScanMejaPage> {
  bool _isScanned = false;

  void _onDetect(BarcodeCapture capture) {
    if (_isScanned) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
      final String code = barcodes.first.rawValue!;
      setState(() {
        _isScanned = true;
      });

      // Simulate validation of QR code
      mySnackBar(
        context: context,
        text: 'Meja berhasil dipindai',
        status: ToastStatus.success,
      );

      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => KatalogPelangganPage(mejaInfo: code),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Scan QR Meja',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          MobileScanner(
            onDetect: _onDetect,
            overlayBuilder: (context, constraints) {
              return Container(
                decoration: ShapeDecoration(
                  shape: QrScannerOverlayShape(
                    borderColor: Warna.primary,
                    borderRadius: 10,
                    borderLength: 30,
                    borderWidth: 10,
                    cutOutSize: MediaQuery.of(context).size.width * 0.7,
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                children: [
                  Text(
                    'Arahkan kamera ke QR Code di meja Anda',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  // Simulasi button for testing in emulator where camera might not work
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Warna.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      if (_isScanned) return;
                      setState(() {
                        _isScanned = true;
                      });
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const KatalogPelangganPage(mejaInfo: 'Meja 5'),
                        ),
                      );
                    },
                    child: const Text('Simulasi Scan (Meja 5)'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Overlay Shape for QR Scanner
class QrScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final double overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;
  final double cutOutBottomOffset;

  const QrScannerOverlayShape({
    this.borderColor = Colors.red,
    this.borderWidth = 3.0,
    this.overlayColor = 150,
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
    this.cutOutBottomOffset = 0,
  });

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path getLeftTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.top)
        ..lineTo(rect.right, rect.top);
    }

    return getLeftTopPath(rect)
      ..lineTo(
        rect.right,
        rect.bottom,
      )
      ..lineTo(
        rect.left,
        rect.bottom,
      )
      ..lineTo(
        rect.left,
        rect.top,
      );
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final height = rect.height;
    final mCutOutSize = cutOutSize;
    final mBorderLength = borderLength;

    final Paint paint = Paint()
      ..color = Color.fromRGBO(0, 0, 0, overlayColor / 255)
      ..style = PaintingStyle.fill;

    final Rect cutOutRect = Rect.fromLTWH(
      rect.left + width / 2 - mCutOutSize / 2,
      rect.top + height / 2 - mCutOutSize / 2 - cutOutBottomOffset,
      mCutOutSize,
      mCutOutSize,
    );

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(rect),
        Path()
          ..addRRect(
            RRect.fromRectAndCorners(
              cutOutRect,
              topLeft: Radius.circular(borderRadius),
              topRight: Radius.circular(borderRadius),
              bottomLeft: Radius.circular(borderRadius),
              bottomRight: Radius.circular(borderRadius),
            ),
          ),
      ),
      paint,
    );

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final path = Path();

    // Top left
    path.moveTo(cutOutRect.left, cutOutRect.top + mBorderLength);
    path.lineTo(cutOutRect.left, cutOutRect.top);
    path.lineTo(cutOutRect.left + mBorderLength, cutOutRect.top);

    // Top right
    path.moveTo(cutOutRect.right - mBorderLength, cutOutRect.top);
    path.lineTo(cutOutRect.right, cutOutRect.top);
    path.lineTo(cutOutRect.right, cutOutRect.top + mBorderLength);

    // Bottom right
    path.moveTo(cutOutRect.right, cutOutRect.bottom - mBorderLength);
    path.lineTo(cutOutRect.right, cutOutRect.bottom);
    path.lineTo(cutOutRect.right - mBorderLength, cutOutRect.bottom);

    // Bottom left
    path.moveTo(cutOutRect.left + mBorderLength, cutOutRect.bottom);
    path.lineTo(cutOutRect.left, cutOutRect.bottom);
    path.lineTo(cutOutRect.left, cutOutRect.bottom - mBorderLength);

    canvas.drawPath(path, borderPaint);
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth * t,
      overlayColor: overlayColor,
      borderRadius: borderRadius * t,
      borderLength: borderLength * t,
      cutOutSize: cutOutSize * t,
      cutOutBottomOffset: cutOutBottomOffset * t,
    );
  }
}
