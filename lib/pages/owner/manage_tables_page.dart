import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_mobile/configuration/configuration.dart';
import 'package:pos_mobile/components/components.dart';
import 'package:tabler_icons/tabler_icons.dart';

enum TableViewMode { grid, list, layout }

class ManageTablesPage extends StatefulWidget {
  const ManageTablesPage({super.key});

  @override
  State<ManageTablesPage> createState() => _ManageTablesPageState();
}

class _ManageTablesPageState extends State<ManageTablesPage> {
  final TextEditingController _searchController = TextEditingController();
  final TransformationController _transformationController =
      TransformationController();
  String _searchQuery = '';
  TableViewMode _viewMode = TableViewMode.grid;
  bool _isEditMode = false;

  // Dummy Initial Tables with coordinates and shapes
  List<Map<String, dynamic>> tables = [
    {
      'id': '1',
      'name': '01',
      'capacity': 2,
      'status': 'Tersedia',
      'area': 'Indoor',
      'x': 50.0,
      'y': 100.0,
    },
    {
      'id': '2',
      'name': '02',
      'capacity': 4,
      'status': 'Terisi',
      'area': 'Indoor',
      'x': 150.0,
      'y': 100.0,
    },
    {
      'id': '3',
      'name': '03',
      'capacity': 4,
      'status': 'Tersedia',
      'area': 'Indoor',
      'x': 250.0,
      'y': 100.0,
    },
    {
      'id': '4',
      'name': '04',
      'capacity': 6,
      'status': 'Tersedia',
      'area': 'Outdoor',
      'x': 50.0,
      'y': 250.0,
    },
    {
      'id': '5',
      'name': 'VIP',
      'capacity': 8,
      'status': 'Tersedia',
      'area': 'VIP Room',
      'x': 150.0,
      'y': 250.0,
    },
  ];

  List<Map<String, dynamic>> get filteredTables {
    return tables.where((table) {
      final matchesSearch =
          table['name'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          table['area'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
      return matchesSearch;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  void _showTableForm({Map<String, dynamic>? table}) {
    final nameController = TextEditingController(text: table?['name'] ?? '');
    final capacityController = TextEditingController(
      text: table?['capacity']?.toString() ?? '2',
    );
    String selectedArea = table?['area'] ?? 'Indoor';
    String selectedStatus = table?['status'] ?? 'Tersedia';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          table == null ? 'Tambah Meja' : 'Edit Meja',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(TablerIcons.x),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    myTextField(
                      controller: nameController,
                      placeholder: 'Contoh: 01',
                      labelText: 'Nama / Nomor Meja',
                    ),
                    const SizedBox(height: 16),
                    myTextField(
                      controller: capacityController,
                      placeholder: '2',
                      labelText: 'Kapasitas (Orang)',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    mySelectField(
                      labelText: 'Area',
                      selectedValue: selectedArea,
                      items: ['Indoor', 'Outdoor', 'VIP Room'],
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => selectedArea = val);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    mySelectField(
                      labelText: 'Status Awal',
                      selectedValue: selectedStatus,
                      items: ['Tersedia', 'Terisi'],
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => selectedStatus = val);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    const SizedBox(height: 30),
                    MyButtonPrimary(
                      onPressed: () {
                        if (nameController.text.isEmpty) {
                          mySnackBar(
                            context: context,
                            text: 'Nama meja wajib diisi',
                            status: ToastStatus.error,
                          );
                          return;
                        }

                        final newTable = {
                          'id':
                              table?['id'] ??
                              DateTime.now().millisecondsSinceEpoch.toString(),
                          'name': nameController.text,
                          'capacity':
                              int.tryParse(capacityController.text) ?? 2,
                          'area': selectedArea,
                          'status': selectedStatus,
                          'x': table?['x'] ?? 100.0,
                          'y': table?['y'] ?? 100.0,
                        };

                        setState(() {
                          if (table == null) {
                            tables.add(newTable);
                            mySnackBar(
                              context: context,
                              text: 'Meja berhasil ditambahkan',
                              status: ToastStatus.success,
                            );
                          } else {
                            // Find real index in the master list
                            int masterIndex = tables.indexWhere(
                              (t) => t['id'] == table['id'],
                            );
                            if (masterIndex != -1) {
                              tables[masterIndex] = newTable;
                            }
                            mySnackBar(
                              context: context,
                              text: 'Meja berhasil diperbarui',
                              status: ToastStatus.success,
                            );
                          }
                        });
                        Navigator.pop(context);
                      },
                      backgroundColor: Warna.primary,
                      foregroundColor: Colors.white,
                      child: Text(
                        'Simpan',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _deleteTable(Map<String, dynamic> table) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Meja?'),
        content: Text(
          'Apakah Anda yakin ingin menghapus Meja ${table['name']}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                tables.removeWhere((t) => t['id'] == table['id']);
              });
              Navigator.pop(context);
              mySnackBar(
                context: context,
                text: 'Meja berhasil dihapus',
                status: ToastStatus.success,
              );
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Warna.bg,
      appBar: MyAppBar(
        title: 'Kelola Meja',
        isCenter: true,
        actions: [
          PopupMenuButton<TableViewMode>(
            initialValue: _viewMode,
            icon: Icon(
              _viewMode == TableViewMode.layout
                  ? TablerIcons.armchair
                  : _viewMode == TableViewMode.grid
                  ? TablerIcons.layout_grid
                  : TablerIcons.list,
            ),
            onSelected: (mode) => setState(() => _viewMode = mode),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: TableViewMode.layout,
                child: Text('Mode Denah'),
              ),
              const PopupMenuItem(
                value: TableViewMode.grid,
                child: Text('Mode Grid'),
              ),
              const PopupMenuItem(
                value: TableViewMode.list,
                child: Text('Mode List'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar (Only for non-layout mode)
          if (_viewMode != TableViewMode.layout)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: myTextField(
                controller: _searchController,
                placeholder: 'Cari meja atau area...',
                prefix: const Icon(TablerIcons.search, size: 20),
              ),
            ),

          if (_viewMode == TableViewMode.layout) _buildToolbar(),

          // Main View
          Expanded(
            child: tables.isEmpty
                ? _buildEmptyState()
                : _viewMode == TableViewMode.layout
                ? _buildLayoutView()
                : _viewMode == TableViewMode.grid
                ? _buildGridView()
                : _buildListView(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTableForm(),
        backgroundColor: Warna.primary,
        child: const Icon(TablerIcons.plus, color: Colors.white),
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          Text(
            'Denah Tata Letak',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Text(
            _isEditMode ? 'Edit Mode Aktif' : 'View Mode',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: _isEditMode ? Colors.red : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          Switch(
            value: _isEditMode,
            onChanged: (val) => setState(() => _isEditMode = val),
            activeThumbColor: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(TablerIcons.table_off, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Belum ada meja',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.9,
      ),
      itemCount: filteredTables.length,
      itemBuilder: (context, index) => _buildCompactCard(filteredTables[index]),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredTables.length,
      itemBuilder: (context, index) => _buildListTile(filteredTables[index]),
    );
  }

  Widget _buildLayoutView() {
    return Container(
      color: Colors.grey[200],
      child: InteractiveViewer(
        transformationController: _transformationController,
        boundaryMargin: const EdgeInsets.all(500),
        minScale: 0.5,
        maxScale: 2.0,
        child: Stack(
          children: [
            // Floors background
            Container(
              width: 1000,
              height: 1000,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: GridPaper(
                color: Colors.grey.withValues(alpha: 0.05),
                divisions: 1,
                subdivisions: 5,
                interval: 100,
              ),
            ),
            ...tables.map((table) => _buildPositionedTable(table)),
          ],
        ),
      ),
    );
  }

  Widget _buildPositionedTable(Map<String, dynamic> table) {
    return Positioned(
      left: table['x'],
      top: table['y'],
      child: _isEditMode
          ? GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  // Grid snapping (per 10 pixels)
                  double newX = (table['x'] + details.delta.dx);
                  double newY = (table['y'] + details.delta.dy);
                  table['x'] = (newX / 10).roundToDouble() * 10;
                  table['y'] = (newY / 10).roundToDouble() * 10;
                });
              },
              child: _buildVisualTable(table, isDragging: true),
            )
          : BounceTapper(
              onTap: () => _showTableForm(table: table),
              child: _buildVisualTable(table),
            ),
    );
  }

  Widget _buildVisualTable(
    Map<String, dynamic> table, {
    bool isDragging = false,
  }) {
    bool isAvailable = table['status'] == 'Tersedia';
    bool isOccupied = table['status'] == 'Terisi';

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: isDragging
            ? Colors.blue.withValues(alpha: 0.5)
            : isOccupied
            ? Colors.red[400]
            : isAvailable
            ? Warna.primary
            : Colors.grey,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isDragging ? Colors.blue : Colors.white.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              table['name'],
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(TablerIcons.users, size: 10, color: Colors.white70),
                const SizedBox(width: 2),
                Text(
                  table['capacity'].toString(),
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactCard(Map<String, dynamic> table) {
    bool isAvailable = table['status'] == 'Tersedia';
    bool isOccupied = table['status'] == 'Terisi';

    return BounceTapper(
      onTap: () => _showTableForm(table: table),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: isOccupied
              ? Colors.red[400]
              : isAvailable
              ? Warna.primary
              : Colors.grey[400],
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              table['name'],
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w900,
                fontSize: 24,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(TablerIcons.users, size: 12, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    'Cap: ${table['capacity']}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(Map<String, dynamic> table) {
    bool isAvailable = table['status'] == 'Tersedia';
    bool isOccupied = table['status'] == 'Terisi';

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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color:
                  (isOccupied
                          ? Colors.red
                          : isAvailable
                          ? Warna.primary
                          : Colors.grey)
                      .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                table['name'],
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: isOccupied
                      ? Colors.red
                      : isAvailable
                      ? Warna.primary
                      : Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Meja ${table['name']} • ${table['area']}',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: (isOccupied ? Colors.red : Colors.green)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        table['status'],
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isOccupied ? Colors.red : Colors.green,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(TablerIcons.users, size: 12, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text(
                      '${table['capacity']} Kursi',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showTableForm(table: table),
            icon: Icon(TablerIcons.edit, size: 20, color: Warna.secondary),
          ),
          IconButton(
            onPressed: () => _deleteTable(table),
            icon: const Icon(TablerIcons.trash, size: 20, color: Colors.red),
          ),
        ],
      ),
    );
  }
}
