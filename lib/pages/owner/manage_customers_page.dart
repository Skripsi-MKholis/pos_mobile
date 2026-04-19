import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tabler_icons/tabler_icons.dart';
import '../../models/customer_model.dart';
import '../../providers/auth_provider.dart';
import '../../repositories/customer_repository.dart';
import '../../configuration/configuration.dart';
import '../../components/components.dart';

class ManageCustomersPage extends StatefulWidget {
  const ManageCustomersPage({super.key});

  @override
  State<ManageCustomersPage> createState() => _ManageCustomersPageState();
}

class _ManageCustomersPageState extends State<ManageCustomersPage> {
  final _repository = CustomerRepository();
  List<CustomerModel> _customers = [];
  List<CustomerModel> _filteredCustomers = [];
  bool _isLoading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCustomers();
    _searchController.addListener(_filterCustomers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers({bool force = false}) async {
    setState(() => _isLoading = true);
    try {
      final storeId = context.read<AuthProvider>().selectedStore?.id;
      if (storeId != null) {
        final data = await _repository.getCustomers(storeId, forceRefresh: force);
        setState(() {
          _customers = data;
          _filterCustomers();
        });
      }
    } catch (e) {
      if (!mounted) return;
      mySnackBar(
        context: context,
        text: 'Gagal memuat data pelanggan: $e',
        status: ToastStatus.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _filterCustomers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCustomers = _customers.where((c) {
        return c.name.toLowerCase().contains(query) ||
            (c.phone?.contains(query) ?? false) ||
            (c.email?.toLowerCase().contains(query) ?? false);
      }).toList();
    });
  }

  void _showCustomerForm({CustomerModel? customer}) {
    final nameController = TextEditingController(text: customer?.name ?? '');
    final phoneController = TextEditingController(text: customer?.phone ?? '');
    final emailController = TextEditingController(text: customer?.email ?? '');
    final notesController = TextEditingController(text: customer?.notes ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
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
                customer == null ? 'Tambah Pelanggan Baru' : 'Edit Pelanggan',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              myTextField(
                controller: nameController,
                labelText: 'Nama Lengkap *',
                placeholder: 'Masukkan nama pelanggan',
              ),
              const SizedBox(height: 16),
              myTextField(
                controller: phoneController,
                labelText: 'Nomor Telepon',
                placeholder: '08xx',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              myTextField(
                controller: emailController,
                labelText: 'Email',
                placeholder: 'email@pelanggan.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              myTextField(
                controller: notesController,
                labelText: 'Catatan',
                placeholder: 'Catatan tambahan...',
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: MyButtonPrimary(
                      onPressed: () => Navigator.pop(context),
                      backgroundColor: Colors.grey[200]!,
                      foregroundColor: Colors.black,
                      isOutlined: true,
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MyButtonPrimary(
                      onPressed: () async {
                        if (nameController.text.isEmpty) {
                          mySnackBar(
                            context: context,
                            text: 'Nama wajib diisi',
                            status: ToastStatus.warning,
                          );
                          return;
                        }

                        final storeId = context.read<AuthProvider>().selectedStore?.id;
                        if (storeId == null) return;

                        final newCustomer = CustomerModel(
                          id: customer?.id ?? '',
                          storeId: storeId,
                          name: nameController.text,
                          phone: phoneController.text,
                          email: emailController.text,
                          notes: notesController.text,
                          createdAt: customer?.createdAt ?? DateTime.now(),
                          updatedAt: DateTime.now(),
                        );

                        try {
                          if (customer == null) {
                            await _repository.createCustomer(newCustomer);
                          } else {
                            await _repository.updateCustomer(newCustomer);
                          }
                          if (!context.mounted) return;
                          Navigator.pop(context);
                          _loadCustomers(force: true);
                          mySnackBar(
                            context: context,
                            text: 'Berhasil menyimpan data pelanggan',
                            status: ToastStatus.success,
                          );
                        } catch (e) {
                          if (!context.mounted) return;
                          mySnackBar(
                            context: context,
                            text: 'Gagal menyimpan: $e',
                            status: ToastStatus.error,
                          );
                        }
                      },
                      backgroundColor: Warna.primary,
                      foregroundColor: Colors.white,
                      child: const Text('Simpan'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteCustomer(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pelanggan?'),
        content: const Text('Data pelanggan yang dihapus tidak dapat dikembalikan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _repository.deleteCustomer(id);
        _loadCustomers(force: true);
        if (mounted) {
          mySnackBar(
            context: context,
            text: 'Pelanggan berhasil dihapus',
            status: ToastStatus.success,
          );
        }
      } catch (e) {
        if (mounted) {
          mySnackBar(
            context: context,
            text: 'Gagal menghapus: $e',
            status: ToastStatus.error,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Warna.bg,
      appBar: AppBar(
        title: Text(
          'Manajemen Pelanggan',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: () => _loadCustomers(force: true),
            icon: const Icon(TablerIcons.refresh, size: 20),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredCustomers.isEmpty
                    ? _buildEmptyState()
                    : _buildCustomerList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCustomerForm(),
        backgroundColor: Warna.primary,
        child: const Icon(TablerIcons.plus, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: myTextField(
        controller: _searchController,
        placeholder: 'Cari nama, telepon, atau email...',
        prefix: const Icon(TablerIcons.search, size: 20, color: Colors.grey),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(TablerIcons.users, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isEmpty
                ? 'Belum ada pelanggan'
                : 'Pencarian tidak ditemukan',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredCustomers.length,
      itemBuilder: (context, index) {
        final customer = _filteredCustomers[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: Warna.primary.withValues(alpha: 0.1),
              child: Text(
                customer.name[0].toUpperCase(),
                style: GoogleFonts.plusJakartaSans(
                  color: Warna.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              customer.name,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (customer.phone != null && customer.phone!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(TablerIcons.phone, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          customer.phone!,
                          style: GoogleFonts.plusJakartaSans(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                if (customer.email != null && customer.email!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(TablerIcons.mail, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          customer.email!,
                          style: GoogleFonts.plusJakartaSans(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _showCustomerForm(customer: customer);
                } else if (value == 'delete') {
                  _deleteCustomer(customer.id!);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(TablerIcons.edit, size: 18),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(TablerIcons.trash, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Hapus', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
