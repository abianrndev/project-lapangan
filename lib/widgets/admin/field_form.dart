import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../models/field.dart';
import '../custom_button.dart';

class FieldForm extends StatefulWidget {
  final Field? field; // null untuk create, non-null untuk edit
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
  final _imageUrlController = TextEditingController();
  bool _isAvailable = true;

  @override
  void initState() {
    super.initState();
    if (widget.field != null) {
      // Populate form if editing
      _nameController.text = widget.field!.name;
      _descriptionController.text = widget.field!.description;
      _priceController.text = widget.field!.price.toString();
      _imageUrlController.text = widget.field!.imageUrl;
      _isAvailable = widget.field!.isAvailable;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit({
        'name': _nameController.text,
        'description': _descriptionController.text,
        'price': double.parse(_priceController.text),
        'imageUrl': _imageUrlController.text,
        'isAvailable': _isAvailable,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Nama Lapangan',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Nama lapangan tidak boleh kosong';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: 'Deskripsi',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Deskripsi tidak boleh kosong';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _priceController,
            decoration: InputDecoration(
              labelText: 'Harga per Jam',
              prefixText: 'Rp ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Harga tidak boleh kosong';
              }
              if (double.tryParse(value) == null) {
                return 'Harga harus berupa angka';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _imageUrlController,
            decoration: InputDecoration(
              labelText: 'URL Gambar',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'URL gambar tidak boleh kosong';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Status Lapangan'),
            subtitle: Text(
              _isAvailable ? 'Tersedia' : 'Tidak Tersedia',
              style: AppTextStyles.bodyText.copyWith(
                color: _isAvailable
                    ? AppColors.secondary
                    : AppColors.textSecondary,
              ),
            ),
            value: _isAvailable,
            onChanged: (bool value) {
              setState(() {
                _isAvailable = value;
              });
            },
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: widget.field == null ? 'Tambah Lapangan' : 'Simpan Perubahan',
            onPressed: _submitForm,
          ),
        ],
      ),
    );
  }
}
