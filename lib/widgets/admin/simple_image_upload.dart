import 'dart:io';
import 'package:flutter/material.dart';
import '../../services/simple_image_service.dart';
import '../../constants/colors.dart';

class SimpleImageUpload extends StatefulWidget {
  final String? currentImagePath;
  final Function(String?) onImageSelected;

  const SimpleImageUpload({
    Key? key,
    this.currentImagePath,
    required this.onImageSelected,
  }) : super(key: key);

  @override
  State<SimpleImageUpload> createState() => _SimpleImageUploadState();
}

class _SimpleImageUploadState extends State<SimpleImageUpload> {
  String? _selectedImagePath;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _selectedImagePath = widget.currentImagePath;
  }

  Future<void> _pickAndSaveImage() async {
    setState(() {
      _isUploading = true;
    });

    try {
      // Pick image
      final File? imageFile = await SimpleImageService.pickImageFromGallery();
      if (imageFile == null) {
        setState(() {
          _isUploading = false;
        });
        return;
      }

      // Save image with unique name
      final String fileName = 'field_${DateTime.now().millisecondsSinceEpoch}';
      final String? savedPath = await SimpleImageService.saveImageToLocal(
        imageFile,
        fileName,
      );

      if (savedPath != null) {
        // Delete old image if exists and it's not the original
        if (_selectedImagePath != null &&
            _selectedImagePath != widget.currentImagePath &&
            !_selectedImagePath!.startsWith('http')) {
          await SimpleImageService.deleteImage(_selectedImagePath!);
        }

        setState(() {
          _selectedImagePath = savedPath;
          _isUploading = false;
        });

        widget.onImageSelected(savedPath);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Foto berhasil dipilih! '),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() {
          _isUploading = false;
        });
        _showErrorDialog('Gagal menyimpan foto.');
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
                await SimpleImageService.deleteImage(_selectedImagePath!);
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
        const Text(
          'Foto Lapangan',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
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
              child: ElevatedButton.icon(
                onPressed: _isUploading ? null : _pickAndSaveImage,
                icon: _isUploading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.photo_library),
                label: Text(_isUploading ? 'Menyimpan...' : 'Pilih Foto'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            if (_selectedImagePath != null &&
                _selectedImagePath!.isNotEmpty) ...[
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
          Icon(Icons.image_outlined, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(
            'Belum ada foto',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
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
            style: TextStyle(color: Colors.red[600], fontSize: 14),
          ),
        ],
      ),
    );
  }
}
