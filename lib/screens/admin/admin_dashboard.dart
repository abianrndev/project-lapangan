import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../widgets/admin/stat_card.dart';
import '../../widgets/admin/quick_action_card.dart';
import '../../widgets/admin/admin_drawer.dart';
import '../../providers/booking_provider.dart';
import '../../providers/field_provider.dart';
import '../../providers/auth_provider.dart';
import '../../database/database_helper.dart';
import 'package:go_router/go_router.dart';
import '../../models/field.dart';
import 'field_management.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  Map<String, dynamic>? _stats;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    final fieldProvider = Provider.of<FieldProvider>(context, listen: false);
    
    // Load bookings and fields
    await Future.wait([
      bookingProvider.loadAllBookings(),
      fieldProvider.loadFields(),
    ]);

    // Load statistics
    final db = DatabaseHelper.instance;
    final stats = await db.getDashboardStats();
    
    setState(() {
      _stats = stats;
      _isLoadingStats = false;
    });
  }

  String _formatCurrency(dynamic value) {
    if (value == null) return 'Rp 0';
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final recentBookings = bookingProvider.bookings.take(5).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Dashboard Admin',
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
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Statistics Grid
              _isLoadingStats
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        StatCard(
                          title: 'Total Booking',
                          value: _stats!['totalBookings'].toString(),
                          icon: Icons.calendar_today,
                          color: AppColors.primary,
                        ),
                        StatCard(
                          title: 'Lapangan Aktif',
                          value: _stats!['activeFields'].toString(),
                          icon: Icons.sports_soccer,
                          color: AppColors.secondary,
                        ),
                        StatCard(
                          title: 'Pendapatan Hari Ini',
                          value: _formatCurrency(_stats!['todayRevenue']),
                          icon: Icons.payments,
                          color: Colors.orange,
                        ),
                        StatCard(
                          title: 'Pengguna Aktif',
                          value: _stats!['activeUsers'].toString(),
                          icon: Icons.people,
                          color: Colors.purple,
                        ),
                      ],
                    ),

              const SizedBox(height: 24),

              // Quick Actions
              Text('Menu Cepat', style: AppTextStyles.headerMedium),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  QuickActionCard(
                    title: 'Kelola\nLapangan',
                    icon: Icons.sports_soccer,
                    onTap: () => context.push('/admin/fields'),
                  ),
                  QuickActionCard(
                    title: 'Kelola\nBooking',
                    icon: Icons.calendar_month,
                    onTap: () => context.push('/admin/bookings'),
                  ),
                  QuickActionCard(
                    title: 'Refresh',
                    icon: Icons.refresh,
                    onTap: _loadData,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Recent Bookings
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Booking Terbaru', style: AppTextStyles.headerMedium),
                  TextButton(
                    onPressed: () => context.push('/admin/bookings'),
                    child: const Text('Lihat Semua'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              bookingProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : recentBookings.isEmpty
                      ? Card(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Center(
                              child: Text(
                                'Belum ada booking',
                                style: AppTextStyles.bodyText.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: recentBookings.length,
                          itemBuilder: (context, index) {
                            final booking = recentBookings[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                title: Text(
                                  booking.userName,
                                  style: AppTextStyles.headerMedium,
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(
                                      '${booking.fieldName} • ${booking.startTime} - ${booking.endTime}',
                                      style: AppTextStyles.bodyText,
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(booking.status)
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        booking.status.toUpperCase(),
                                        style: AppTextStyles.bodyText.copyWith(
                                          color: _getStatusColor(booking.status),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.chevron_right),
                                  onPressed: () {
                                    context.push('/admin/bookings');
                                  },
                                ),
                              ),
                            );
                          },
                        ),
            ],
          ),
        ),
      ),
      drawer: const AdminDrawer(),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return AppColors.secondary;
      case 'rejected':
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.grey;
      default:
        return AppColors.accent;
    }
  }
}

