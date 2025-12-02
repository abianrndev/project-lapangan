import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../models/field.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../../widgets/field_carousel.dart';
import '../../widgets/custom_button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/booking/booking_dialog.dart';
import '../../models/booking.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({Key? key}) : super(key: key);

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  int _currentNavIndex = 0;

  // Contoh data lapangan (nanti akan diganti dengan data dari backend)
  final List<Field> _fields = [
    Field(
      id: '1',
      name: 'Lapangan A',
      description: 'Lapangan futsal indoor dengan rumput sintetis',
      price: 150000,
      imageUrl: 'https://example.com/field-a.jpg',
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
    const phoneNumber = '6281234567890';
    const message = 'Halo, saya ingin memesan lapangan...';
    final url =
        'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
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
          'SportField',
          style: AppTextStyles.headerLarge.copyWith(color: AppColors.primary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            color: AppColors.textPrimary,
            onPressed: () {},
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
                    'Mau olahraga apa hari ini?',
                    style: AppTextStyles.headerLarge,
                  ),
                ],
              ),
            ),

            // ---------- FieldCarousel: TARUH KODE BOOKING DIALOG DI SINI ----------
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
                      // buka dialog booking untuk field yg dipilih
                      showDialog(
                        context: context,
                        builder: (context) => BookingDialog(
                          field: field,
                          onSubmit: (userName, date, startTime, endTime, note) {
                            final id = DateTime.now().millisecondsSinceEpoch
                                .toString();
                            final booking = Booking(
                              id: id,
                              fieldId: field.id,
                              fieldName: field.name,
                              userName: userName,
                              date: date,
                              startTime: startTime,
                              endTime: endTime,
                              note: note,
                            );
                            Provider.of<BookingProvider>(
                              context,
                              listen: false,
                            ).addBooking(booking);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Permintaan booking dikirim (status: Pending)',
                                ),
                              ),
                            );
                          },
                        ),
                      );
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
          setState(() => _currentNavIndex = index);
        },
      ),
    );
  }
}
