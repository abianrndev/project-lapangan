import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class SimpleImageService {
  // Pick image using file_picker (more stable)
  static Future<File?> pickImageFromGallery() async {
    try {
      print('🔍 Opening file picker.. .');

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        print('✅ Image selected: ${result.files.single.path}');
        return File(result.files.single.path!);
      } else {
        print('❌ No image selected');
        return null;
      }
    } catch (e) {
      print('💥 Error picking image: $e');
      return null;
    }
  }

  // Save image to app directory
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
      print('✅ Image saved to: $savedPath');

      // Verify file exists and is accessible
      if (await savedImage.exists()) {
        print('✅ File exists and accessible');
        return savedImage.path;
      } else {
        print('❌ File was saved but cannot be accessed');
        return null;
      }
    } catch (e) {
      print('💥 Error saving image: $e');
      return null;
    }
  }

  // Delete image file
  static Future<bool> deleteImage(String imagePath) async {
    try {
      if (imagePath.startsWith('http')) {
        // Don't delete network images
        return true;
      }

      final File imageFile = File(imagePath);
      if (await imageFile.exists()) {
        await imageFile.delete();
        print('✅ Image deleted:  $imagePath');
        return true;
      }
      return false;
    } catch (e) {
      print('💥 Error deleting image: $e');
      return false;
    }
  }
}
