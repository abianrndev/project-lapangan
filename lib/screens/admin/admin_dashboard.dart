import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../widgets/admin/stat_card.dart';
import '../../widgets/admin/quick_action_card.dart';
import '../../widgets/admin/admin_drawer.dart';
import 'package:go_router/go_router.dart';
import '../../models/field.dart';
import 'field_management.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  // Contoh data untuk statistik
  final Map<String, dynamic> _stats = {
    'totalBookings': '24',
    'activeFields': '3',
    'todayRevenue': 'Rp 1.5jt',
    'activeUsers': '45',
  };

  // Contoh data untuk booking terbaru
  final List<Map<String, dynamic>> _recentBookings = [
    {
      'customerName': 'Abian nanda',
      'fieldName': 'Lapangan A',
      'time': '14:00 - 16:00',
      'status': 'Pending',
    },
    {
      'customerName': 'nyambik bakar',
      'fieldName': 'Lapangan B',
      'time': '16:00 - 18:00',
      'status': 'Confirmed',
    },
  ];

  @override
  Widget build(BuildContext context) {
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
            icon: const Icon(Icons.notifications_outlined),
            color: AppColors.textPrimary,
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
          IconButton(
            icon: const CircleAvatar(
              backgroundImage: NetworkImage(
                'https://ui-avatars.com/api/?name=Admin&background=random',
              ),
            ),
            onPressed: () {
              // TODO: Implement profile menu
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statistics Grid
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                StatCard(
                  title: 'Total Booking',
                  value: _stats['totalBookings'],
                  icon: Icons.calendar_today,
                  color: AppColors.primary,
                ),
                StatCard(
                  title: 'Lapangan Aktif',
                  value: _stats['activeFields'],
                  icon: Icons.sports_soccer,
                  color: AppColors.secondary,
                ),
                StatCard(
                  title: 'Pendapatan Hari Ini',
                  value: _stats['todayRevenue'],
                  icon: Icons.payments,
                  color: Colors.orange,
                ),
                StatCard(
                  title: 'Pengguna Aktif',
                  value: _stats['activeUsers'],
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
                  title: 'Tambah\nLapangan',
                  icon: Icons.add_circle,
                  onTap: () {
                    // TODO: Navigate to add field screen
                  },
                ),
                QuickActionCard(
                  title: 'Kelola\nBooking',
                  icon: Icons.calendar_month,
                  onTap: () {
                    // TODO: Navigate to booking management
                  },
                ),
                QuickActionCard(
                  title: 'Atur\nJadwal',
                  icon: Icons.schedule,
                  onTap: () {
                    // TODO: Navigate to schedule management
                  },
                ),
                QuickActionCard(
                  title: 'Kelola\nDiskon',
                  icon: Icons.discount,
                  onTap: () {
                    // TODO: Navigate to discount management
                  },
                ),
                QuickActionCard(
                  title: 'Laporan',
                  icon: Icons.bar_chart,
                  onTap: () {
                    // TODO: Navigate to reports
                  },
                ),
                QuickActionCard(
                  title: 'Pengaturan',
                  icon: Icons.settings,
                  onTap: () {
                    // TODO: Navigate to settings
                  },
                ),
                QuickActionCard(
                  title: 'Kelola\nLapangan',
                  icon: Icons.sports_soccer,
                  onTap: () => context.push('/admin/fields'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Recent Bookings
            Text('Booking Terbaru', style: AppTextStyles.headerMedium),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentBookings.length,
              itemBuilder: (context, index) {
                final booking = _recentBookings[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      booking['customerName'],
                      style: AppTextStyles.headerMedium,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          '${booking['fieldName']} • ${booking['time']}',
                          style: AppTextStyles.bodyText,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: booking['status'] == 'Confirmed'
                                ? AppColors.secondary.withOpacity(0.1)
                                : AppColors.accent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            booking['status'],
                            style: AppTextStyles.bodyText.copyWith(
                              color: booking['status'] == 'Confirmed'
                                  ? AppColors.secondary
                                  : AppColors.accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () {
                        // TODO: Navigate to booking detail
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      drawer: const AdminDrawer(),
    );
  }
}
