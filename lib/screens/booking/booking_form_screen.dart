import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../models/field.dart';
import '../../models/booking.dart';
import '../../providers/booking_provider.dart';
import '../../providers/auth_provider.dart';

class BookingFormScreen extends StatefulWidget {
  final Field field;

  const BookingFormScreen({super.key, required this.field});

  @override
  State<BookingFormScreen> createState() {
    print('✅ BookingFormScreen createState called');
    return _BookingFormScreenState();
  }
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();

  DateTime? _selectedDate;
  String? _startTime;
  String? _endTime;
  bool _isSubmitting = false;

  final List<String> _timeSlots = [
    '08:00',
    '09:00',
    '10:00',
    '11:00',
    '12:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
    '17:00',
    '18:00',
    '19:00',
    '20:00',
    '21:00',
    '22:00',
  ];

  @override
  void initState() {
    super.initState();
    print('✅ BookingFormScreen initState called');
  }

  int get _duration {
    if (_startTime == null || _endTime == null) return 0;
    final startHour = int.parse(_startTime!.split(':')[0]);
    final endHour = int.parse(_endTime!.split(':')[0]);
    return endHour - startHour;
  }

  int get _totalPrice {
    return _duration * widget.field.pricePerHour;
  }

  @override
  Widget build(BuildContext context) {
    print('✅ BookingFormScreen build called');
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Booking ${widget.field.name}',
          style: AppTextStyles.headerLarge.copyWith(color: AppColors.primary),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Field Info Card
                    _buildFieldInfoCard(),
                    const SizedBox(height: 24),

                    // Date Selection
                    _buildSectionTitle('Pilih Tanggal'),
                    const SizedBox(height: 12),
                    _buildDateSelector(),
                    const SizedBox(height: 24),

                    // Time Selection
                    if (_selectedDate != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Pilih Waktu'),
                          const SizedBox(height: 12),
                          _buildTimeSelector(),
                          const SizedBox(height: 24),
                        ],
                      ),

                    // Duration & Price Summary
                    if (_startTime != null && _endTime != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPriceSummary(),
                          const SizedBox(height: 24),
                        ],
                      ),

                    // Notes
                    _buildSectionTitle('Catatan (Opsional)'),
                    const SizedBox(height: 12),
                    _buildNotesField(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Action
          _buildBottomAction(),
        ],
      ),
    );
  }

  Widget _buildFieldInfoCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 80,
                height: 80,
                child: widget.field.getImageWidget(
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.field.name, style: AppTextStyles.headerMedium),
                  const SizedBox(height: 4),
                  Text(
                    widget.field.description,
                    style: AppTextStyles.bodyText.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_formatCurrency(widget.field.pricePerHour)}/jam',
                    style: AppTextStyles.headerMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.headerMedium.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildDateSelector() {
    return InkWell(
      onTap: _selectDate,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedDate != null
                    ? _formatDate(_selectedDate!)
                    : 'Pilih tanggal booking',
                style: AppTextStyles.bodyText.copyWith(
                  color: _selectedDate != null
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Jam Mulai',
                style: AppTextStyles.bodyText.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              _buildTimeDropdown(
                initialValue: _startTime,
                hint: 'Pilih jam mulai',
                onChanged: (value) {
                  setState(() {
                    _startTime = value;
                    // Reset end time if start time changed
                    if (_endTime != null) {
                      final startIndex = _timeSlots.indexOf(_startTime!);
                      final endIndex = _timeSlots.indexOf(_endTime!);
                      if (endIndex <= startIndex) {
                        _endTime = null;
                      }
                    }
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Jam Selesai',
                style: AppTextStyles.bodyText.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              _buildTimeDropdown(
                initialValue: _endTime,
                hint: 'Pilih jam selesai',
                enabled: _startTime != null,
                items: _startTime != null ? _getEndTimeOptions() : [],
                onChanged: (value) {
                  setState(() {
                    _endTime = value;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeDropdown({
    required String? initialValue,
    required String hint,
    required ValueChanged<String?>? onChanged,
    bool enabled = true,
    List<String>? items,
  }) {
    return DropdownButtonFormField<String>(
      value: initialValue,
      hint: Text(hint),
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: (items ?? _timeSlots).map((time) {
        return DropdownMenuItem(value: time, child: Text(time));
      }).toList(),
      onChanged: enabled ? onChanged : null,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Pilih waktu';
        }
        return null;
      },
    );
  }

  Widget _buildPriceSummary() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ringkasan Booking',
              style: AppTextStyles.headerMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildSummaryRow('Tanggal', _formatDate(_selectedDate!)),
            _buildSummaryRow('Waktu', '$_startTime - $_endTime'),
            _buildSummaryRow('Durasi', '$_duration jam'),
            _buildSummaryRow(
              'Harga per jam',
              _formatCurrency(widget.field.pricePerHour),
            ),

            const Divider(height: 24),

            _buildSummaryRow(
              'Total Bayar',
              _formatCurrency(_totalPrice),
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyText.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyText.copyWith(
              fontWeight: FontWeight.bold,
              color: isTotal ? AppColors.primary : AppColors.textPrimary,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _noteController,
      decoration: InputDecoration(
        hintText: 'Tambahkan catatan untuk admin.. .',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.all(16),
      ),
      maxLines: 3,
      maxLength: 200,
    );
  }

  Widget _buildBottomAction() {
    final bool hasSelectedDate = _selectedDate != null;
    final bool hasStartTime = _startTime != null;
    final bool hasEndTime = _endTime != null;
    final bool isNotSubmitting = !_isSubmitting;

    final bool canSubmit =
        hasSelectedDate && hasStartTime && hasEndTime && isNotSubmitting;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_totalPrice > 0)
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Pembayaran: ',
                      style: AppTextStyles.headerMedium,
                    ),
                    Text(
                      _formatCurrency(_totalPrice),
                      style: AppTextStyles.headerLarge.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canSubmit ? _submitBooking : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBackgroundColor: Colors.grey[300],
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Konfirmasi Booking',
                      style: AppTextStyles.headerMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getEndTimeOptions() {
    if (_startTime == null) return [];
    final startIndex = _timeSlots.indexOf(_startTime!);
    return _timeSlots.skip(startIndex + 1).toList();
  }

  void _selectDate() async {
    final now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && context.mounted) {
      setState(() {
        _selectedDate = pickedDate;
        // Reset time selections when date changes
        _startTime = null;
        _endTime = null;
      });
    }
  }

  void _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final bookingProvider = Provider.of<BookingProvider>(
        context,
        listen: false,
      );

      final currentUser = authProvider.currentUser;
      if (currentUser == null) {
        throw Exception('User tidak ditemukan');
      }

      final booking = Booking(
        userId: currentUser.id!,
        fieldId: widget.field.id!,
        bookingDate: _selectedDate!.toIso8601String().split('T')[0],
        startTime: _startTime!,
        endTime: _endTime!,
        totalPrice: _totalPrice,
        status: 'pending',
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        userName: currentUser.name,
        fieldName: widget.field.name,
      );

      final success = await bookingProvider.createBooking(booking);

      setState(() {
        _isSubmitting = false;
      });

      if (success == true && context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 28),
                const SizedBox(width: 8),
                const Text('Booking Berhasil! '),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Booking Anda telah berhasil dibuat. '),
                const SizedBox(height: 8),
                const Text('Admin akan mengkonfirmasi booking Anda segera.'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detail Booking:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Lapangan: ${widget.field.name}'),
                      Text('Tanggal: ${_formatDate(_selectedDate!)}'),
                      Text('Waktu: $_startTime - $_endTime'),
                      Text('Total: ${_formatCurrency(_totalPrice)}'),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Close booking form
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text('OK', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal membuat booking.  Silakan coba lagi. '),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    final formatter = DateFormat('EEEE, dd MMMM yyyy', 'id');
    return formatter.format(date);
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
