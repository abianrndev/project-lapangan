import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../database/database_helper.dart';

class BookingProvider extends ChangeNotifier {
  List<Booking> _bookings = [];
  bool _isLoading = false;

  List<Booking> get bookings => List.unmodifiable(_bookings);
  bool get isLoading => _isLoading;

  // Load all bookings from database
  Future<void> loadAllBookings() async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = DatabaseHelper.instance;
      _bookings = await db.getAllBookings();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load bookings for a specific user
  Future<void> loadBookingsByUserId(int userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = DatabaseHelper.instance;
      _bookings = await db.getBookingsByUserId(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load bookings for a specific field
  Future<void> loadBookingsByFieldId(int fieldId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = DatabaseHelper.instance;
      _bookings = await db.getBookingsByFieldId(fieldId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get bookings for a specific field (from loaded bookings)
  List<Booking> bookingsForField(int fieldId) =>
      _bookings.where((b) => b.fieldId == fieldId).toList();

  // Get bookings for a specific user (from loaded bookings)
  List<Booking> bookingsForUser(int userId) =>
      _bookings.where((b) => b.userId == userId).toList();

  // Get booking by ID
  Booking? getById(int id) {
    try {
      return _bookings.firstWhere((b) => b.id == id);
    } catch (e) {
      return null;
    }
  }

  // Create new booking
  Future<Map<String, dynamic>> createBooking(Booking booking) async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = DatabaseHelper.instance;

      // Check for conflicts
      final hasConflict = await db.hasBookingConflict(
        booking.fieldId,
        booking.bookingDate,
        booking.startTime,
        booking.endTime,
      );

      if (hasConflict) {
        _isLoading = false;
        notifyListeners();
        return {
          'success': false,
          'message': 'Jadwal bertabrakan dengan booking lain',
        };
      }

      final id = await db.createBooking(booking);

      if (id > 0) {
        // Reload bookings
        await loadAllBookings();
        return {
          'success': true,
          'message': 'Booking berhasil dibuat',
          'id': id,
        };
      }

      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'Gagal membuat booking'};
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  // Update booking status
  Future<bool> updateBookingStatus(int bookingId, String newStatus) async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = DatabaseHelper.instance;

      // Get booking details first (untuk revenue calculation)
      final booking = _bookings.firstWhere((b) => b.id == bookingId);

      // Update status di database
      final result = await db.updateBookingStatus(bookingId, newStatus);

      if (result > 0) {
        // If status is "completed", add to today's revenue
        if (newStatus == 'completed') {
          await _addToTodaysRevenue(booking.totalPrice);
        }

        // Update local state
        final index = _bookings.indexWhere((b) => b.id == bookingId);
        if (index != -1) {
          _bookings[index] = booking.copyWith(status: newStatus);
        }

        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Add booking revenue to today's earnings
  Future<void> _addToTodaysRevenue(int amount) async {
    try {
      final db = DatabaseHelper.instance;
      await db.addTodaysRevenue(amount);
    } catch (e) {
      print('Error adding to revenue: $e');
    }
  }

  // Delete booking
  Future<bool> deleteBooking(int bookingId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = DatabaseHelper.instance;
      final result = await db.deleteBooking(bookingId);

      if (result > 0) {
        _bookings.removeWhere((b) => b.id == bookingId);
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
