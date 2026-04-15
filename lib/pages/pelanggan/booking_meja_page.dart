import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_mobile/configuration/configuration.dart';
import 'package:tabler_icons/tabler_icons.dart';
import 'package:pos_mobile/components/components.dart';

class BookingMejaPage extends StatefulWidget {
  const BookingMejaPage({super.key});

  @override
  State<BookingMejaPage> createState() => _BookingMejaPageState();
}

class _BookingMejaPageState extends State<BookingMejaPage> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _guestCount = 2;
  String _selectedArea = 'Indoor';

  final List<String> _areas = ['Indoor', 'Outdoor', 'VIP Room'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Booking Meja',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Toko Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Warna.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Warna.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(TablerIcons.building_store, color: Warna.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Toko Berkah Jaya',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Jl. Sudirman No. 123, Jakarta',
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
            const SizedBox(height: 32),

            // Tanggal
            Text(
              'Tanggal Kedatangan',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );
                if (date != null) {
                  setState(() {
                    _selectedDate = date;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(TablerIcons.calendar, color: Colors.grey[600]),
                    const SizedBox(width: 12),
                    Text(
                      _selectedDate == null
                          ? 'Pilih Tanggal'
                          : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                      style: GoogleFonts.plusJakartaSans(
                        color: _selectedDate == null ? Colors.grey[500] : Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Jam
            Text(
              'Jam Kedatangan',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: const TimeOfDay(hour: 18, minute: 0),
                );
                if (time != null) {
                  setState(() {
                    _selectedTime = time;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(TablerIcons.clock, color: Colors.grey[600]),
                    const SizedBox(width: 12),
                    Text(
                      _selectedTime == null
                          ? 'Pilih Waktu'
                          : _selectedTime!.format(context),
                      style: GoogleFonts.plusJakartaSans(
                        color: _selectedTime == null ? Colors.grey[500] : Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Jumlah Tamu
            Text(
              'Jumlah Tamu',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (_guestCount > 1) {
                      setState(() {
                        _guestCount--;
                      });
                    }
                  },
                  icon: const Icon(TablerIcons.minus),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      '$_guestCount Orang',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _guestCount++;
                    });
                  },
                  icon: const Icon(TablerIcons.plus),
                  style: IconButton.styleFrom(
                    backgroundColor: Warna.primary.withValues(alpha: 0.1),
                    foregroundColor: Warna.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Area Pilihan
            Text(
              'Preferensi Area',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              children: _areas.map((area) {
                final isSelected = _selectedArea == area;
                return ChoiceChip(
                  label: Text(area),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedArea = area;
                      });
                    }
                  },
                  backgroundColor: Colors.white,
                  selectedColor: Warna.primary.withValues(alpha: 0.1),
                  labelStyle: TextStyle(
                    color: isSelected ? Warna.primary : Colors.grey[600],
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color: isSelected ? Warna.primary : Colors.grey.shade300,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 40),

            MyButtonPrimary(
              onPressed: () {
                if (_selectedDate == null || _selectedTime == null) {
                  mySnackBar(
                    context: context,
                    text: 'Mohon lengkapi tanggal dan waktu',
                    status: ToastStatus.error,
                  );
                  return;
                }

                mySnackBar(
                  context: context,
                  text: 'Permintaan booking meja berhasil dikirim',
                  status: ToastStatus.success,
                );

                Future.delayed(const Duration(seconds: 1), () {
                  if (!context.mounted) return;
                  Navigator.pop(context);
                });
              },
              backgroundColor: Warna.primary,
              foregroundColor: Colors.white,
              child: const Center(
                child: Text(
                  'Konfirmasi Booking',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
