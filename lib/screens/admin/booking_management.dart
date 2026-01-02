import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../providers/booking_provider.dart';
import '../../models/booking.dart';

class BookingManagementScreen extends StatefulWidget {
  const BookingManagementScreen({Key? key}) : super(key: key);

  @override
  State<BookingManagementScreen> createState() =>
      _BookingManagementScreenState();
}

class _BookingManagementScreenState extends State<BookingManagementScreen> {
  @override
  void initState() {
    super.initState();
    // Load all bookings
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookingProvider>(context, listen: false).loadAllBookings();
    });
  }

  String _formatCurrency(int amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);
    final bookings = bookingProvider.bookings.reversed.toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Kelola Booking',
          style: AppTextStyles.headerMedium.copyWith(color: AppColors.primary),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              bookingProvider.loadAllBookings();
            },
          ),
        ],
      ),
      body: bookingProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : bookings.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 64,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada booking',
                        style: AppTextStyles.headerMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
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
                              '${_formatDate(b.bookingDate)} • ${b.startTime} - ${b.endTime}',
                              style: AppTextStyles.bodyText,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Total: ${_formatCurrency(b.totalPrice)}',
                              style: AppTextStyles.bodyText.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            if (b.note != null && b.note!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Catatan: ${b.note}',
                                style: AppTextStyles.bodyText.copyWith(
                                  color: AppColors.textSecondary,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Chip(
                              label: Text(b.status.toUpperCase()),
                              backgroundColor:
                                  _statusColor(b.status).withOpacity(0.15),
                              labelStyle: AppTextStyles.bodyText.copyWith(
                                color: _statusColor(b.status),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        isThreeLine: true,
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'delete') {
                              // Show confirmation dialog
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Hapus Booking'),
                                  content: const Text(
                                    'Apakah Anda yakin ingin menghapus booking ini?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Batal'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text(
                                        'Hapus',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmed == true && mounted) {
                                final success =
                                    await bookingProvider.removeBooking(b.id!);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        success
                                            ? 'Booking berhasil dihapus'
                                            : 'Gagal menghapus booking',
                                      ),
                                      backgroundColor: success
                                          ? AppColors.secondary
                                          : Colors.red,
                                    ),
                                  );
                                }
                              }
                            } else {
                              // Update status
                              final success =
                                  await bookingProvider.updateStatus(b.id!, value);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      success
                                          ? 'Status berhasil diperbarui'
                                          : 'Gagal memperbarui status',
                                    ),
                                    backgroundColor: success
                                        ? AppColors.secondary
                                        : Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'confirmed',
                              child: Text('Konfirmasi'),
                            ),
                            const PopupMenuItem(
                              value: 'rejected',
                              child: Text('Tolak'),
                            ),
                            const PopupMenuItem(
                              value: 'completed',
                              child: Text('Selesai'),
                            ),
                            const PopupMenuItem(
                              value: 'cancelled',
                              child: Text('Batalkan'),
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

