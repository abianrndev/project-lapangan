import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../models/field.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../../widgets/field_carousel.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/booking/booking_dialog.dart';
import '../../providers/field_provider.dart';
import '../../providers/auth_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({Key? key}) : super(key: key);

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load fields from database
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FieldProvider>(context, listen: false).loadAvailableFields();
    });
  }

  void _onNavTap(int index) {
    if (index == _currentNavIndex) return;
    
    setState(() {
      _currentNavIndex = index;
    });

    switch (index) {
      case 0:
        // Already on home
        break;
      case 1:
        context.push('/user/bookings').then((_) {
          setState(() {
            _currentNavIndex = 0;
          });
        });
        break;
      case 2:
        context.push('/user/profile').then((_) {
          setState(() {
            _currentNavIndex = 0;
          });
        });
        break;
    }
  }

  void _launchWhatsApp() async {
    const phoneNumber = '6281234567890';
    const message = 'Halo, saya ingin memesan lapangan...';
    final url =
        'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}';
    
    try {
      final uri = Uri.parse(url);
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      
      if (!launched && mounted) {
        _showErrorDialog('Tidak dapat membuka WhatsApp');
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Error: ${e.toString()}');
      }
    }
  }

  void _showErrorDialog(String message) {
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
    final fieldProvider = Provider.of<FieldProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final fields = fieldProvider.availableFields;

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
            icon: const Icon(Icons.logout),
            color: AppColors.textPrimary,
            onPressed: () {
              authProvider.logout();
              context.go('/login');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await fieldProvider.loadAvailableFields();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                      authProvider.currentUser?.name ?? 'User',
                      style: AppTextStyles.headerLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Mau olahraga apa hari ini?',
                      style: AppTextStyles.bodyText.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Field Carousel
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
                    fieldProvider.isLoading
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : fields.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.sports_soccer,
                                        size: 64,
                                        color: AppColors.textSecondary,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Belum ada lapangan tersedia',
                                        style: AppTextStyles.bodyText.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : FieldCarousel(
                                fields: fields,
                                onFieldSelected: (field) {
                                  // Open booking dialog
                                  showDialog(
                                    context: context,
                                    builder: (context) => BookingDialog(
                                      field: field,
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
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentNavIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
