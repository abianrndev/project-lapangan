import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ImagePickerTestScreen extends StatefulWidget {
  const ImagePickerTestScreen({super.key});

  @override
  State<ImagePickerTestScreen> createState() => _ImagePickerTestScreenState();
}

class _ImagePickerTestScreenState extends State<ImagePickerTestScreen> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickImageFromGallery() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('🔍 Attempting to pick image from gallery...');

      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        print('✅ Image picked successfully: ${pickedFile.path}');
        setState(() {
          _selectedImage = File(pickedFile.path);
          _isLoading = false;
        });
        _showSuccessDialog('✅ Image selected successfully!');
      } else {
        print('❌ No image selected');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('💥 Error picking image: $e');
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Error picking image: $e');
    }
  }

  Future<void> _pickImageFromCamera() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('📷 Attempting to open camera...');

      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        print('✅ Photo taken successfully: ${pickedFile.path}');
        setState(() {
          _selectedImage = File(pickedFile.path);
          _isLoading = false;
        });
        _showSuccessDialog('✅ Photo taken successfully!');
      } else {
        print('❌ No photo taken');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('💥 Error taking photo: $e');
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Error taking photo: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('❌ Error'),
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

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('✅ Success'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧪 Image Picker Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Status
              Text(
                '📱 Image Picker Test',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              // Image preview container
              Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 2),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[100],
                ),
                child: _isLoading
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Processing... '),
                          ],
                        ),
                      )
                    : _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          _selectedImage!,
                          width: 250,
                          height: 250,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_outlined,
                            size: 80,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No image selected',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: 30),

              // Gallery button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _pickImageFromGallery,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('📁 Pick from Gallery'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // Camera button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _pickImageFromCamera,
                  icon: const Icon(Icons.photo_camera),
                  label: const Text('📷 Take Photo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Status info
              if (_selectedImage != null) ...[
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '✅ Image Info: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text('Path: ${_selectedImage!.path}'),
                      Text('Size: ${_getFileSize(_selectedImage!)}'),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // Instructions
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '💡 Instructions:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text('1. Test Gallery access'),
                    Text('2. Test Camera access'),
                    Text('3. Check VS Code console for logs'),
                    Text('4. Report any errors'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getFileSize(File file) {
    try {
      int bytes = file.lengthSync();
      if (bytes < 1024) return '$bytes B';
      if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } catch (e) {
      return 'Unknown size';
    }
  }
}
