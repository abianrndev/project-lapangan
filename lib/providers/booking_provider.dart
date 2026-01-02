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
      return {
        'success': false,
        'message': 'Gagal membuat booking',
      };
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // Update booking status
  Future<bool> updateStatus(int bookingId, String status) async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = DatabaseHelper.instance;
      final result = await db.updateBookingStatus(bookingId, status);
      
      if (result > 0) {
        // Update local booking
        final index = _bookings.indexWhere((b) => b.id == bookingId);
        if (index != -1) {
          _bookings[index].status = status;
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

  // Delete booking
  Future<bool> removeBooking(int bookingId) async {
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

