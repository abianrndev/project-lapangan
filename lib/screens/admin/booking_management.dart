import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../providers/booking_provider.dart';
import '../../models/booking.dart';

class BookingManagementScreen extends StatefulWidget {
  const BookingManagementScreen({super.key});

  @override
  State<BookingManagementScreen> createState() =>
      _BookingManagementScreenState();
}

class _BookingManagementScreenState extends State<BookingManagementScreen> {
  @override
  void initState() {
    super.initState();
    // Load all bookings when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookingProvider>(context, listen: false).loadAllBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Kelola Booking',
          style: AppTextStyles.headerLarge.copyWith(color: AppColors.primary),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.textPrimary,
          onPressed: () => context.go('/admin'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            color: AppColors.textPrimary,
            onPressed: () {
              Provider.of<BookingProvider>(
                context,
                listen: false,
              ).loadAllBookings();
            },
          ),
        ],
      ),
      body: Consumer<BookingProvider>(
        builder: (context, bookingProvider, child) {
          if (bookingProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final bookings = bookingProvider.bookings;

          if (bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today,
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
                  const SizedBox(height: 8),
                  Text(
                    'Booking dari user akan muncul di sini',
                    style: AppTextStyles.bodyText.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await bookingProvider.loadAllBookings();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return _buildBookingCard(context, booking, bookingProvider);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildBookingCard(
    BuildContext context,
    Booking booking,
    BookingProvider provider,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    booking.fieldName,
                    style: AppTextStyles.headerMedium,
                  ),
                ),
                _buildStatusBadge(booking.status),
              ],
            ),
            const SizedBox(height: 12),

            // Booking details
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(booking.userName, style: AppTextStyles.bodyText),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _formatDate(booking.bookingDate),
                    style: AppTextStyles.bodyText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${booking.startTime} - ${booking.endTime}',
                    style: AppTextStyles.bodyText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Icon(
                  Icons.payments_outlined,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _formatCurrency(booking.totalPrice),
                    style: AppTextStyles.bodyText.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),

            if (booking.note != null && booking.note!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.note_outlined,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      booking.note!,
                      style: AppTextStyles.bodyText.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),

            // Action buttons
            _buildActionButtons(context, booking, provider),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    String displayText;
    IconData icon;

    switch (status) {
      case 'pending':
        backgroundColor = Colors.orange;
        displayText = 'Pending';
        icon = Icons.schedule;
        break;
      case 'confirmed':
        backgroundColor = Colors.blue;
        displayText = 'Dikonfirmasi';
        icon = Icons.check_circle;
        break;
      case 'completed':
        backgroundColor = Colors.green;
        displayText = 'Selesai';
        icon = Icons.done_all;
        break;
      case 'cancelled':
        backgroundColor = Colors.red;
        displayText = 'Dibatalkan';
        icon = Icons.cancel;
        break;
      case 'rejected':
        backgroundColor = Colors.red[800]!;
        displayText = 'Ditolak';
        icon = Icons.close;
        break;
      default:
        backgroundColor = Colors.grey;
        displayText = status;
        icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            displayText,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    Booking booking,
    BookingProvider provider,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // PENDING STATE:  Show Konfirmasi & Tolak
          if (booking.status == 'pending') ...[
            ElevatedButton.icon(
              onPressed: () => _updateBookingStatus(
                context,
                provider,
                booking.id!,
                'confirmed',
              ),
              icon: const Icon(Icons.check, size: 16),
              label: const Text('Konfirmasi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () => _updateBookingStatus(
                context,
                provider,
                booking.id!,
                'rejected',
              ),
              icon: const Icon(Icons.close, size: 16),
              label: const Text('Tolak'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
          ],

          // CONFIRMED STATE: Show Selesai & Batal
          if (booking.status == 'confirmed') ...[
            ElevatedButton.icon(
              onPressed: () => _updateBookingStatus(
                context,
                provider,
                booking.id!,
                'completed',
              ),
              icon: const Icon(Icons.done_all, size: 16),
              label: const Text('Selesai'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () => _updateBookingStatus(
                context,
                provider,
                booking.id!,
                'cancelled',
              ),
              icon: const Icon(Icons.cancel, size: 16),
              label: const Text('Batal'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
          ],

          // Show spacer if there are previous buttons
          if (booking.status == 'pending' || booking.status == 'confirmed')
            const SizedBox(width: 8),

          // DELETE:  Always available
          ElevatedButton.icon(
            onPressed: () => _deleteBooking(context, provider, booking.id!),
            icon: const Icon(Icons.delete, size: 16),
            label: const Text('Hapus'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[800],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  // Update booking status with confirmation dialog
  void _updateBookingStatus(
    BuildContext context,
    BookingProvider provider,
    int bookingId,
    String status,
  ) {
    String actionText = '';
    switch (status) {
      case 'confirmed':
        actionText = 'mengkonfirmasi';
        break;
      case 'rejected':
        actionText = 'menolak';
        break;
      case 'completed':
        actionText = 'menyelesaikan';
        break;
      case 'cancelled':
        actionText = 'membatalkan';
        break;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Konfirmasi ${actionText.toUpperCase()}'),
        content: Text('Apakah Anda yakin ingin $actionText booking ini? '),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final success = await provider.updateBookingStatus(
                bookingId,
                status,
              );

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Booking berhasil ${actionText}!'),
                    backgroundColor: status == 'completed'
                        ? Colors.green
                        : Colors.blue,
                  ),
                );

                // Show revenue notification if completed
                if (status == 'completed') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('💰 Pendapatan hari ini telah diperbarui!'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              }
            },
            child: Text(actionText.toUpperCase()),
          ),
        ],
      ),
    );
  }

  // Delete booking with confirmation dialog
  void _deleteBooking(
    BuildContext context,
    BookingProvider provider,
    int bookingId,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Booking'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus booking ini?\n\nData yang dihapus tidak dapat dikembalikan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final success = await provider.deleteBooking(bookingId);

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Booking berhasil dihapus!'
                          : 'Gagal menghapus booking',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('HAPUS'),
          ),
        ],
      ),
    );
  }

  // Helper method to format date
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final formatter = DateFormat('EEEE, dd MMMM yyyy', 'id');
      return formatter.format(date);
    } catch (e) {
      return dateString;
    }
  }

  // Helper method to format currency
  String _formatCurrency(int amount) {
    final formatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }
}
