import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../providers/booking_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/booking.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Load user bookings
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final bookingProvider = Provider.of<BookingProvider>(
        context,
        listen: false,
      );

      if (authProvider.currentUser != null) {
        bookingProvider.loadUserBookings(authProvider.currentUser!.id!);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Booking> _filterBookings(List<Booking> bookings, String status) {
    if (status == 'all') return bookings;
    return bookings.where((booking) => booking.status == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Pesanan Saya',
          style: AppTextStyles.headerLarge.copyWith(color: AppColors.primary),
        ),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 12,
          ),
          tabs: const [
            Tab(text: 'Semua'),
            Tab(text: 'Pending'),
            Tab(text: 'Dikonfirmasi'),
            Tab(text: 'Selesai'),
          ],
        ),
      ),
      body: Consumer<BookingProvider>(
        builder: (context, bookingProvider, child) {
          if (bookingProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final allBookings = bookingProvider.userBookings;

          return TabBarView(
            controller: _tabController,
            children: [
              _buildBookingList(allBookings),
              _buildBookingList(_filterBookings(allBookings, 'pending')),
              _buildBookingList(_filterBookings(allBookings, 'confirmed')),
              _buildBookingList(_filterBookings(allBookings, 'completed')),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBookingList(List<Booking> bookings) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada pesanan',
              style: AppTextStyles.headerMedium.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pesanan Anda akan muncul di sini',
              style: AppTextStyles.bodyText.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final bookingProvider = Provider.of<BookingProvider>(
          context,
          listen: false,
        );

        if (authProvider.currentUser != null) {
          await bookingProvider.loadUserBookings(authProvider.currentUser!.id!);
        }
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return _buildBookingCard(booking);
        },
      ),
    );
  }

  Widget _buildBookingCard(Booking booking) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with field name and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    booking.fieldName,
                    style: AppTextStyles.headerMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                _buildStatusBadge(booking.status),
              ],
            ),

            const SizedBox(height: 12),

            // Booking details
            _buildDetailRow(
              Icons.calendar_today,
              'Tanggal',
              _formatDate(booking.bookingDate),
            ),
            const SizedBox(height: 8),

            _buildDetailRow(
              Icons.access_time,
              'Waktu',
              '${booking.startTime} - ${booking.endTime}',
            ),
            const SizedBox(height: 8),

            _buildDetailRow(
              Icons.payments,
              'Total Bayar',
              _formatCurrency(booking.totalPrice),
              isPrice: true,
            ),

            if (booking.note != null && booking.note!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildDetailRow(Icons.note, 'Catatan', booking.note!),
            ],

            const SizedBox(height: 16),

            // Action buttons based on status
            _buildActionButtons(booking),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    bool isPrice = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodyText.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.bodyText.copyWith(
                  fontWeight: isPrice ? FontWeight.bold : FontWeight.normal,
                  color: isPrice ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            displayText,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Booking booking) {
    switch (booking.status) {
      case 'pending':
        return Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _cancelBooking(booking),
                icon: const Icon(Icons.cancel, size: 16),
                label: const Text('Batalkan'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _contactAdmin(booking),
                icon: const Icon(Icons.phone, size: 16),
                label: const Text('Hubungi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        );

      case 'confirmed':
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _contactAdmin(booking),
            icon: const Icon(Icons.phone, size: 16),
            label: const Text('Hubungi Admin'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        );

      case 'completed':
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _bookAgain(booking),
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Pesan Lagi'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        );

      default:
        return Container();
    }
  }

  void _cancelBooking(Booking booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan Pesanan'),
        content: Text(
          'Apakah Anda yakin ingin membatalkan pesanan "${booking.fieldName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              // Update booking status to cancelled
              final bookingProvider = Provider.of<BookingProvider>(
                context,
                listen: false,
              );
              final success = await bookingProvider.updateBookingStatus(
                booking.id!,
                'cancelled',
              );

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Pesanan dibatalkan'
                          : 'Gagal membatalkan pesanan',
                    ),
                    backgroundColor: success ? Colors.orange : Colors.red,
                  ),
                );
              }
            },
            child: const Text(
              'Ya, Batalkan',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _contactAdmin(Booking booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hubungi Admin'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pesanan: ${booking.fieldName}'),
            Text('Tanggal: ${_formatDate(booking.bookingDate)}'),
            const SizedBox(height: 16),
            const Text('Pilih cara menghubungi admin:'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final whatsappUrl =
                  'https://wa.me/6281234567890? text=Halo admin, saya ingin bertanya tentang booking ${booking.fieldName} pada ${_formatDate(booking.bookingDate)}';
              if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
                await launchUrl(Uri.parse(whatsappUrl));
              }
            },
            child: const Text('WhatsApp'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final phoneUrl = 'tel:+6281234567890';
              if (await canLaunchUrl(Uri.parse(phoneUrl))) {
                await launchUrl(Uri.parse(phoneUrl));
              }
            },
            child: const Text('Telepon'),
          ),
        ],
      ),
    );
  }

  void _bookAgain(Booking booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pesan Lagi'),
        content: Text('Ingin memesan ${booking.fieldName} lagi? '),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to booking form with pre-filled field
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Fitur "Pesan Lagi" untuk ${booking.fieldName} akan segera hadir',
                  ),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            child: const Text('Ya'),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final formatter = DateFormat('EEEE, dd MMMM yyyy', 'id');
      return formatter.format(date);
    } catch (e) {
      return dateString;
    }
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
