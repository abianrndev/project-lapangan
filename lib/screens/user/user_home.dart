import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../models/field.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../../widgets/field_carousel.dart';
import '../../widgets/custom_button.dart';
import 'package:url_launcher/url_launcher.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({Key? key}) : super(key: key);

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  int _currentNavIndex = 0;

  // ini cuma mockup pak , nanti diganti real data
  final List<Field> _fields = [
    Field(
      id: '1',
      name: 'Lapangan A',
      description: 'Lapangan futsal indoor dengan rumput sintetis',
      price: 50000,
      imageUrl: 'https://contoh.com/field-a.jpg',
    ),
    Field(
      id: '2',
      name: 'Lapangan B',
      description: 'Lapangan basket indoor dengan lantai vinyl',
      price: 200000,
      imageUrl: 'https://example.com/field-b.jpg',
    ),
  ];

  void _launchWhatsApp() async {
    // Ganti nomor WhatsApp admin sesuai kebutuhan
    const phoneNumber = '6281234567890';
    const message = 'Halo, saya ingin memesan lapangan...';

    final url =
        'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      // Tampilkan error dialog jika tidak bisa membuka WhatsApp
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Tidak dapat membuka WhatsApp'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          '19jt Lapangan Padel',
          style: AppTextStyles.headerLarge.copyWith(color: AppColors.primary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            color: AppColors.textPrimary,
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Selamat Datang,', style: AppTextStyles.bodyText),
                  Text(
                    'Siap untuk futsal hari ini?',
                    style: AppTextStyles.headerLarge,
                  ),
                ],
              ),
            ),

            // Featured Fields Carousel
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Lapangan Tersedia',
                      style: AppTextStyles.headerMedium,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FieldCarousel(
                    fields: _fields,
                    onFieldSelected: (field) {
                      // TODO: Navigate to field detail
                    },
                  ),
                ],
              ),
            ),

            // Quick Booking Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Booking Cepat', style: AppTextStyles.headerMedium),
                      const SizedBox(height: 16),
                      Text(
                        'Hubungi admin kami melalui WhatsApp untuk booking lapangan sekarang!',
                        style: AppTextStyles.bodyText,
                      ),
                      const SizedBox(height: 16),
                      CustomButton(
                        text: 'Chat Admin WhatsApp',
                        onPressed: _launchWhatsApp,
                        isFullWidth: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });
        },
      ),
    );
  }
}
