import 'dart:io';
import 'package:flutter/material.dart'; // ← ADD:  Flutter widgets
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageService {
  static final ImagePicker _picker = ImagePicker();

  // Pick image from gallery or camera
  static Future<File?> pickImage({
    ImageSource source = ImageSource.gallery,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80, // Compress image
        maxWidth: 800,
        maxHeight: 600,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      // Use debugPrint instead of print for production
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  // Save image to app directory and return path
  static Future<String?> saveImageToLocal(
    File imageFile,
    String fileName,
  ) async {
    try {
      // Get app documents directory
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String imagesDir = path.join(appDir.path, 'field_images');

      // Create images directory if doesn't exist
      final Directory imagesDirDirectory = Directory(imagesDir);
      if (!await imagesDirDirectory.exists()) {
        await imagesDirDirectory.create(recursive: true);
      }

      // Generate unique filename
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String extension = path.extension(imageFile.path);
      final String newFileName = '${fileName}_$timestamp$extension';
      final String savedPath = path.join(imagesDir, newFileName);

      // Copy file to app directory
      final File savedImage = await imageFile.copy(savedPath);
      return savedImage.path;
    } catch (e) {
      debugPrint('Error saving image: $e');
      return null;
    }
  }

  // Delete image file
  static Future<bool> deleteImage(String imagePath) async {
    try {
      final File imageFile = File(imagePath);
      if (await imageFile.exists()) {
        await imageFile.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting image:  $e');
      return false;
    }
  }

  // Show image source selection dialog
  static Future<ImageSource?> showImageSourceDialog(
    BuildContext context,
  ) async {
    return showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pilih Sumber Foto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Kamera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeri'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );
  }
}
