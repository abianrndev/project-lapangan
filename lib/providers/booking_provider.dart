import 'package:flutter/material.dart';
import '../models/booking.dart';

class BookingProvider extends ChangeNotifier {
  final List<Booking> _bookings = [];

  List<Booking> get bookings => List.unmodifiable(_bookings);

  List<Booking> bookingForFiekd(String fieldId) =>
      _bookings.where((b) => b.fieldId == fieldId).toList();

  List<Booking> bookingsForUser(String userName) =>
      _bookings.where((b) => b.userName == userName).toList();

  Booking? getById(String id) =>
      _bookings.firstWhere((b) => b.id == id, orElse: () => null as Booking);

  void addBooking(Booking booking) {
    _bookings.add(booking);
    notifyListeners();
  }

  void updateStatus(String bookingId, String status) {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      _bookings[index].status = status;
      notifyListeners();
    }
  }

  void removeBooking(String bookingId) {
    _bookings.removeWhere((b) => b.id == bookingId);
    notifyListeners();
  }

  //untuk dev, seed sample data
  void seed(List<Booking> sample) {
    _bookings.clear();
    _bookings.addAll(sample);
    notifyListeners();
  }
}
