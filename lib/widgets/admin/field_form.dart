import 'package:flutter/material.dart';
import '../../models/field.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import 'simple_image_upload.dart';

class FieldForm extends StatefulWidget {
  final Field? field;
  final Function(Map<String, dynamic>) onSubmit;

  const FieldForm({Key? key, this.field, required this.onSubmit})
    : super(key: key);

  @override
  State<FieldForm> createState() => _FieldFormState();
}

class _FieldFormState extends State<FieldForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  String? _selectedImagePath;
  bool _isAvailable = true;

  @override
  void initState() {
    super.initState();
    if (widget.field != null) {
      _nameController.text = widget.field!.name;
      _descriptionController.text = widget.field!.description;
      _priceController.text = widget.field!.pricePerHour.toString();
      _selectedImagePath = widget.field!.imageUrl;
      _isAvailable = widget.field!.isAvailable;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final formData = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'pricePerHour': int.parse(_priceController.text),
        'imageUrl': _selectedImagePath ?? '',
        'isAvailable': _isAvailable,
      };

      print('🚀 Submitting field data: ');
      print('   Name: ${formData['name']}');
      print('   Image: ${formData['imageUrl']}');

      widget.onSubmit(formData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image upload widget
            SimpleImageUpload(
              currentImagePath: _selectedImagePath,
              onImageSelected: (imagePath) {
                setState(() {
                  _selectedImagePath = imagePath;
                });
                print('📸 Image selected: $imagePath');
              },
            ),

            const SizedBox(height: 20),

            // Name field
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nama Lapangan',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.sports_soccer),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama lapangan tidak boleh kosong';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Description field
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Deskripsi',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.description),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Deskripsi tidak boleh kosong';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Price field
            TextFormField(
              controller: _priceController,
              decoration: InputDecoration(
                labelText: 'Harga per Jam (Rp)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.payments),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Harga tidak boleh kosong';
                }
                final price = int.tryParse(value);
                if (price == null || price <= 0) {
                  return 'Harga harus berupa angka positif';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Availability switch
            SwitchListTile(
              title: const Text('Lapangan Tersedia'),
              subtitle: const Text('Aktifkan jika lapangan dapat dibooking'),
              value: _isAvailable,
              onChanged: (value) {
                setState(() {
                  _isAvailable = value;
                });
              },
              activeColor: AppColors.primary,
            ),

            const SizedBox(height: 24),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  widget.field == null ? 'Tambah Lapangan' : 'Update Lapangan',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
