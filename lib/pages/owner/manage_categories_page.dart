import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_mobile/configuration/configuration.dart';
import 'package:pos_mobile/components/components.dart';
import 'package:tabler_icons/tabler_icons.dart';
import 'package:pos_mobile/pages/owner/apply_category_page.dart';

class ManageCategoriesPage extends StatefulWidget {
  final List<String> currentCategories;

  const ManageCategoriesPage({super.key, required this.currentCategories});

  @override
  State<ManageCategoriesPage> createState() => _ManageCategoriesPageState();
}

class _ManageCategoriesPageState extends State<ManageCategoriesPage> {
  late List<String> categories;
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    // Copy the categories excluding 'Semua' for management
    categories = widget.currentCategories.where((c) => c != 'Semua').toList();
  }

  void _showCategoryForm({String? category, int? index}) {
    final controller = TextEditingController(text: category ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                category == null ? 'Tambah Kategori' : 'Edit Kategori',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              myTextField(
                controller: controller,
                placeholder: 'Nama Kategori',
                labelText: 'Nama Kategori',
              ),
              const SizedBox(height: 32),
              MyButtonPrimary(
                onPressed: () {
                  if (controller.text.isEmpty) {
                    mySnackBar(
                      context: context,
                      text: 'Nama kategori harus diisi!',
                      status: ToastStatus.error,
                    );
                    return;
                  }

                  setState(() {
                    if (index == null) {
                      categories.add(controller.text);
                    } else {
                      categories[index] = controller.text;
                    }
                  });

                  Navigator.pop(context);
                },
                backgroundColor: Warna.primary,
                foregroundColor: Colors.white,
                child: Text(
                  category == null ? 'Simpan' : 'Update',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Hapus Kategori?',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus kategori "${categories[index]}"? Produk dalam kategori ini akan kehilangan kategorinya.',
          style: GoogleFonts.plusJakartaSans(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: TextStyle(color: Colors.grey[600])),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                categories.removeAt(index);
              });
              Navigator.pop(context);
              mySnackBar(
                context: context,
                text: 'Kategori berhasil dihapus',
                status: ToastStatus.success,
              );
            },
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
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
        title: 'Kelola Kategori',
        isCenter: true,
        leading: IconButton(
          icon: const Icon(TablerIcons.chevron_left),
          onPressed: () {
            // Return updated list including 'Semua'
            Navigator.pop(context, ['Semua', ...categories]);
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
            icon: Icon(
              _isGridView ? TablerIcons.list : TablerIcons.layout_grid,
              color: Warna.primary,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: categories.isEmpty
          ? _buildEmptyState()
          : _isGridView
              ? GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    return Container(
                      padding: const EdgeInsets.all(12),
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Warna.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              TablerIcons.category,
                              color: Warna.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            categories[index],
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(TablerIcons.playlist_add,
                                    color: Colors.green, size: 18),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ApplyCategoryPage(
                                        categoryName: categories[index],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(TablerIcons.edit,
                                    color: Colors.blue, size: 18),
                                onPressed: () => _showCategoryForm(
                                  category: categories[index],
                                  index: index,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(TablerIcons.trash,
                                    color: Colors.red, size: 18),
                                onPressed: () => _confirmDelete(index),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
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
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Warna.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              TablerIcons.category,
                              color: Warna.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              categories[index],
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  TablerIcons.playlist_add,
                                  color: Colors.green,
                                  size: 20,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ApplyCategoryPage(
                                        categoryName: categories[index],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  TablerIcons.edit,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                                onPressed: () => _showCategoryForm(
                                  category: categories[index],
                                  index: index,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  TablerIcons.trash,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                onPressed: () => _confirmDelete(index),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryForm(),
        backgroundColor: Warna.primary,
        child: const Icon(TablerIcons.plus, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(TablerIcons.category_2, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Belum ada kategori',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan kategori untuk produk Anda',
            style: GoogleFonts.plusJakartaSans(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
