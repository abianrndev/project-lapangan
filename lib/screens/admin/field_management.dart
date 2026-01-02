import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../models/field.dart';
import '../../providers/field_provider.dart';
import '../../widgets/admin/field_form.dart';
import 'package:go_router/go_router.dart';

class FieldManagementScreen extends StatefulWidget {
  const FieldManagementScreen({Key? key}) : super(key: key);

  @override
  State<FieldManagementScreen> createState() => _FieldManagementScreenState();
}

class _FieldManagementScreenState extends State<FieldManagementScreen> {
  @override
  void initState() {
    super.initState();
    // Load fields from database
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FieldProvider>(context, listen: false).loadFields();
    });
  }

  void _showAddEditFieldDialog({Field? field}) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  field == null ? 'Tambah Lapangan' : 'Edit Lapangan',
                  style: AppTextStyles.headerLarge,
                ),
                const SizedBox(height: 16),
                FieldForm(
                  field: field,
                  onSubmit: (data) async {
                    final fieldProvider = Provider.of<FieldProvider>(
                      context,
                      listen: false,
                    );

                    bool success;
                    if (field == null) {
                      // Create new field
                      final newField = Field(
                        name: data['name'],
                        description: data['description'],
                        pricePerHour: (data['price'] as double).toInt(),
                        imageUrl: data['imageUrl'],
                        isAvailable: data['isAvailable'],
                      );
                      success = await fieldProvider.createField(newField);
                    } else {
                      // Update existing field
                      final updatedField = field.copyWith(
                        name: data['name'],
                        description: data['description'],
                        pricePerHour: (data['price'] as double).toInt(),
                        imageUrl: data['imageUrl'],
                        isAvailable: data['isAvailable'],
                      );
                      success = await fieldProvider.updateField(updatedField);
                    }

                    if (!mounted) return;

                    Navigator.pop(context);
                    
                    if (success) {
                      _showSuccessSnackBar(
                        field == null
                            ? 'Lapangan berhasil ditambahkan'
                            : 'Lapangan berhasil diperbarui',
                      );
                    } else {
                      _showErrorSnackBar(
                        field == null
                            ? 'Gagal menambahkan lapangan'
                            : 'Gagal memperbarui lapangan',
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Field field) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Lapangan'),
        content: Text('Apakah Anda yakin ingin menghapus ${field.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              final fieldProvider = Provider.of<FieldProvider>(
                context,
                listen: false,
              );
              
              final success = await fieldProvider.deleteField(field.id!);
              
              if (!mounted) return;
              
              Navigator.pop(context);
              
              if (success) {
                _showSuccessSnackBar('Lapangan berhasil dihapus');
              } else {
                _showErrorSnackBar('Gagal menghapus lapangan');
              }
            },
            child: Text('Hapus', style: TextStyle(color: Colors.red[700])),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.secondary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fieldProvider = Provider.of<FieldProvider>(context);
    final fields = fieldProvider.fields;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Kelola Lapangan',
          style: AppTextStyles.headerLarge.copyWith(color: AppColors.primary),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.textPrimary,
          onPressed: () => context.pop(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditFieldDialog(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
      body: fieldProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : fields.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.sports_soccer,
                        size: 64,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada lapangan',
                        style: AppTextStyles.headerMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tekan tombol + untuk menambah lapangan',
                        style: AppTextStyles.bodyText.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: fields.length,
                  itemBuilder: (context, index) {
                    final field = fields[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Field Image
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: Image.network(
                              field.imageUrl,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 200,
                                  color: AppColors.surface,
                                  child: const Icon(Icons.error),
                                );
                              },
                            ),
                          ),
                          // Field Info
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      field.name,
                                      style: AppTextStyles.headerMedium,
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: field.isAvailable
                                            ? AppColors.secondary
                                                .withOpacity(0.1)
                                            : AppColors.textSecondary
                                                .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        field.isAvailable
                                            ? 'Tersedia'
                                            : 'Tidak Tersedia',
                                        style: AppTextStyles.bodyText.copyWith(
                                          color: field.isAvailable
                                              ? AppColors.secondary
                                              : AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  field.description,
                                  style: AppTextStyles.bodyText,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Rp ${field.pricePerHour.toString()}/jam',
                                  style: AppTextStyles.headerMedium.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () =>
                                            _showAddEditFieldDialog(
                                                field: field),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppColors.primary,
                                          side: const BorderSide(
                                            color: AppColors.primary,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: const Text('Edit'),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () =>
                                            _showDeleteConfirmation(field),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.red[700],
                                          side:
                                              BorderSide(color: Colors.red[700]!),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: const Text('Hapus'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}

