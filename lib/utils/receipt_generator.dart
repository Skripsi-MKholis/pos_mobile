import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pos_mobile/models/transaction_model.dart';
import 'package:intl/intl.dart';

class ReceiptGenerator {
  static Future<Uint8List> generateReceipt(TransactionModel transaction) async {
    final pdf = pw.Document();
    final fmt = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text('TOKO BERKAH JAYA',
                        style: pw.TextStyle(
                            fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Jl. Sudirman No. 123, Jakarta',
                        style: const pw.TextStyle(fontSize: 10)),
                    pw.Text('Telp: 0812-3456-7890',
                        style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Divider(thickness: 1, borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('No: ${transaction.localId.substring(0, 8)}',
                      style: const pw.TextStyle(fontSize: 10)),
                  pw.Text(DateFormat('dd/MM/yy HH:mm').format(transaction.createdAt),
                      style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
              pw.Text('Kasir: ${transaction.cashierId}',
                  style: const pw.TextStyle(fontSize: 10)),
              pw.Text('Meja: ${transaction.tableId ?? "-"}',
                  style: const pw.TextStyle(fontSize: 10)),
              pw.SizedBox(height: 5),
              pw.Divider(thickness: 1, borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 5),
              
              // Items
              ...transaction.items.map((item) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(item.productName,
                          style: pw.TextStyle(
                              fontSize: 11, fontWeight: pw.FontWeight.bold)),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('${item.quantity} x ${fmt.format(item.price)}',
                              style: const pw.TextStyle(fontSize: 10)),
                          pw.Text(fmt.format(item.price * item.quantity),
                              style: const pw.TextStyle(fontSize: 10)),
                        ],
                      ),
                      if (item.notes != null && item.notes!.isNotEmpty)
                        pw.Text('Note: ${item.notes}',
                            style: pw.TextStyle(
                                fontSize: 9, fontStyle: pw.FontStyle.italic)),
                    ],
                  ),
                );
              }),
              
              pw.SizedBox(height: 5),
              pw.Divider(thickness: 1, borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 5),
              
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('TOTAL',
                      style: pw.TextStyle(
                          fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  pw.Text(fmt.format(transaction.totalAmount),
                      style: pw.TextStyle(
                          fontSize: 12, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              
              pw.SizedBox(height: 15),
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text('Terima Kasih',
                        style: pw.TextStyle(
                            fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Selamat Menikmati!',
                        style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
