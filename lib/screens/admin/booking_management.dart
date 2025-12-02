import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../providers/booking_provider.dart';
import '../../models/booking.dart';

class BookingManagementScreen extends StatelessWidget {
  const BookingManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);
    final bookings = bookingProvider.bookings.reversed
        .toList(); // terbaru di atas

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Kelola Booking',
          style: AppTextStyles.headerMedium.copyWith(color: AppColors.primary),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: bookings.isEmpty
          ? Center(
              child: Text('Belum ada booking', style: AppTextStyles.bodyText),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final Booking b = bookings[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      '${b.fieldName} • ${b.userName}',
                      style: AppTextStyles.headerMedium,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Text(
                          '${b.date.day}/${b.date.month}/${b.date.year} • ${b.startTime} - ${b.endTime}',
                          style: AppTextStyles.bodyText,
                        ),
                        const SizedBox(height: 6),
                        if (b.note != null && b.note!.isNotEmpty)
                          Text(
                            'Catatan: ${b.note}',
                            style: AppTextStyles.bodyText.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Chip(
                              label: Text(b.status),
                              backgroundColor: _statusColor(
                                b.status,
                              ).withOpacity(0.15),
                              labelStyle: AppTextStyles.bodyText.copyWith(
                                color: _statusColor(b.status),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'dibuat: ${b.createdAt.day}/${b.createdAt.month}/${b.createdAt.year}',
                              style: AppTextStyles.bodyText.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'delete') {
                          bookingProvider.removeBooking(b.id);
                        } else {
                          bookingProvider.updateStatus(b.id, value);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'Confirmed',
                          child: Text('Confirm'),
                        ),
                        const PopupMenuItem(
                          value: 'Rejected',
                          child: Text('Reject'),
                        ),
                        const PopupMenuItem(
                          value: 'Completed',
                          child: Text('Completed'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            'Hapus',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Confirmed':
        return AppColors.secondary;
      case 'Rejected':
        return Colors.red;
      case 'Completed':
        return Colors.grey;
      default:
        return AppColors.accent;
    }
  }
}
