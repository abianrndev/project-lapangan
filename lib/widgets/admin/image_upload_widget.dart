import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/image_service.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';

class ImageUploadWidget extends StatefulWidget {
  final String? currentImagePath;
  final Function(String?) onImageSelected;
  final String placeholder;

  const ImageUploadWidget({
    Key? key,
    this.currentImagePath,
    required this.onImageSelected,
    this.placeholder = 'Upload Foto Lapangan',
  }) : super(key: key);

  @override
  State<ImageUploadWidget> createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends State<ImageUploadWidget> {
  String? _selectedImagePath;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _selectedImagePath = widget.currentImagePath;
  }

  Future<void> _pickAndSaveImage() async {
    // Show source selection dialog
    final ImageSource? source = await ImageService.showImageSourceDialog(
      context,
    );
    if (source == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      // Pick image
      final File? imageFile = await ImageService.pickImage(source: source);
      if (imageFile == null) {
        setState(() {
          _isUploading = false;
        });
        return;
      }

      // Save image with unique name
      final String fileName = 'field_${DateTime.now().millisecondsSinceEpoch}';
      final String? savedPath = await ImageService.saveImageToLocal(
        imageFile,
        fileName,
      );

      if (savedPath != null) {
        // Delete old image if exists and it's not the original
        if (_selectedImagePath != null &&
            _selectedImagePath != widget.currentImagePath &&
            !_selectedImagePath!.startsWith('http')) {
          await ImageService.deleteImage(_selectedImagePath!);
        }

        setState(() {
          _selectedImagePath = savedPath;
          _isUploading = false;
        });

        // Notify parent widget
        widget.onImageSelected(savedPath);
      } else {
        setState(() {
          _isUploading = false;
        });
        _showErrorDialog('Gagal menyimpan foto.  Silakan coba lagi.');
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      _showErrorDialog('Error:  ${e.toString()}');
    }
  }

  Future<void> _removeImage() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Foto'),
        content: const Text('Apakah Anda yakin ingin menghapus foto ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              // Delete image file if it's not the original and not a URL
              if (_selectedImagePath != null &&
                  _selectedImagePath != widget.currentImagePath &&
                  !_selectedImagePath!.startsWith('http')) {
                await ImageService.deleteImage(_selectedImagePath!);
              }

              setState(() {
                _selectedImagePath = null;
              });

              widget.onImageSelected(null);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Foto Lapangan',
          style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),

        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: _buildImageContent(),
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isUploading ? null : _pickAndSaveImage,
                icon: _isUploading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.photo_camera),
                label: Text(_isUploading ? 'Menyimpan...' : 'Pilih Foto'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: AppColors.primary),
                  foregroundColor: AppColors.primary,
                ),
              ),
            ),

            if (_selectedImagePath != null) ...[
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _removeImage,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Hapus'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: Colors.red),
                  foregroundColor: Colors.red,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildImageContent() {
    if (_selectedImagePath != null && _selectedImagePath!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: _selectedImagePath!.startsWith('http')
            ? Image.network(
                _selectedImagePath!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildLoadingPlaceholder();
                },
                errorBuilder: (context, error, stackTrace) {
                  return _buildErrorPlaceholder();
                },
              )
            : Image.file(
                File(_selectedImagePath!),
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildErrorPlaceholder();
                },
              ),
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(
            widget.placeholder,
            style: AppTextStyles.bodyText.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(11),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
          const SizedBox(height: 8),
          Text(
            'Gagal memuat gambar',
            style: AppTextStyles.bodyText.copyWith(color: Colors.red[600]),
          ),
        ],
      ),
    );
  }
}
