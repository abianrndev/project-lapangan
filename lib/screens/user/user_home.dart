import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../providers/field_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../models/field.dart';
import '../../models/booking.dart';
import 'booking_history_screen.dart';
import 'user_profile_screen.dart';
import '../booking/booking_form_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  int _currentNavIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Load data when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final fieldProvider = Provider.of<FieldProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final bookingProvider = Provider.of<BookingProvider>(
        context,
        listen: false,
      );

      fieldProvider.loadFields();
      if (authProvider.currentUser != null) {
        bookingProvider.loadUserBookings(authProvider.currentUser!.id!);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    setState(() {
      _currentNavIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentNavIndex = index;
          });
        },
        children: [
          _buildHomePage(), // 0: Home/Browse Fields
          _buildBookingHistoryPage(), // 1: Booking History/Pesanan
          _buildProfilePage(), // 2: Profile
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        onTap: _onNavTap,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Pesanan',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  // Home page (existing field browsing)
  Widget _buildHomePage() {
    return Consumer<FieldProvider>(
      builder: (context, fieldProvider, child) {
        if (fieldProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final availableFields = fieldProvider.fields
            .where((field) => field.isAvailable)
            .toList();

        if (availableFields.isEmpty) {
          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.sports_soccer,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada lapangan tersedia',
                        style: AppTextStyles.headerMedium.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Lapangan akan segera ditambahkan',
                        style: AppTextStyles.bodyText.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await fieldProvider.loadFields();
          },
          child: CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcomeCard(),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Lapangan Tersedia'),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final field = availableFields[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: _buildFieldCard(field),
                  );
                }, childCount: availableFields.length),
              ),
              // Add bottom padding for last item
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBookingHistoryPage() {
    return const BookingHistoryScreen();
  }

  Widget _buildProfilePage() {
    return const UserProfileScreen();
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      floating: true,
      snap: true,
      title: Text(
        'SportField',
        style: AppTextStyles.headerLarge.copyWith(color: AppColors.primary),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          color: AppColors.textPrimary,
          onPressed: () {
            _showLogoutDialog();
          },
        ),
      ],
    );
  }

  Widget _buildWelcomeCard() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.primary.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                spreadRadius: 0,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selamat Datang! ',
                style: AppTextStyles.headerMedium.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                user?.name ?? 'User',
                style: AppTextStyles.headerLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Temukan dan booking lapangan futsal favoritmu',
                style: AppTextStyles.bodyText.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.headerMedium.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildFieldCard(Field field) {
    print('🏟️ Building field card for: ${field.name}');
    print('🏟️ Field available: ${field.isAvailable}');
    print('🏟️ Field ID:  ${field.id}');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Field Image
          Container(
            height: 150,
            width: double.infinity,
            child: field.getImageWidget(
              width: double.infinity,
              height: 150,
              fit: BoxFit.cover,
              showDebug: false, // Disable debug in production
            ),
          ),

          // Field Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(field.name, style: AppTextStyles.headerMedium),
                const SizedBox(height: 8),
                Text(
                  field.description,
                  style: AppTextStyles.bodyText.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Harga per jam: ',
                          style: AppTextStyles.bodyText.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatCurrency(field.pricePerHour),
                          style: AppTextStyles.headerMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    // ✅ DIRECT NAVIGATION TO BOOKING FORM
                    ElevatedButton(
                      onPressed: () {
                        print('🔥 BUTTON CLICKED for field: ${field.name}');
                        print('🔥 Field ID: ${field.id}');

                        // Show simple alert first
                        try {
                          print('🚀 Step 1: About to navigate.. .');

                          Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    print(
                                      '🚀 Step 2: MaterialPageRoute builder called',
                                    );

                                    try {
                                      print(
                                        '🚀 Step 3: Creating BookingFormScreen...',
                                      );
                                      return BookingFormScreen(field: field);
                                    } catch (e) {
                                      print(
                                        '❌ Error creating BookingFormScreen: $e',
                                      );
                                      rethrow;
                                    }
                                  },
                                ),
                              )
                              .then((result) {
                                print(
                                  '🚀 Step 4: Navigation completed, result: $result',
                                );
                              })
                              .catchError((error) {
                                print('❌ Navigation error:  $error');
                              });
                        } catch (e) {
                          print('❌ Exception during navigation: $e');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Book Sekarang',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );
              authProvider.logout();
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(int amount) {
    final formatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }
}
