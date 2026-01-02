class Booking {
  final int? id;
  final int userId;
  final int fieldId;
  final String fieldName;
  final String userName;
  final String bookingDate; // Store as string (YYYY-MM-DD)
  final String startTime; // "14:00"
  final String endTime; // "16:00"
  final int totalPrice;
  String status; // pending, confirmed, rejected, completed, cancelled
  final String? note;
  final DateTime? createdAt;

  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  bool get isRejected => status == 'rejected';

  // ADD: Available actions based on current state
  bool get canConfirmOrReject => isPending;
  bool get canCompleteOrCancel => isConfirmed;
  bool get canDelete => true; // Admin can always delete

  Booking({
    this.id,
    required this.userId,
    required this.fieldId,
    required this.fieldName,
    required this.userName,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.totalPrice,
    this.status = 'pending',
    this.note,
    this.createdAt,
  });

  // Convert to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'field_id': fieldId,
      'booking_date': bookingDate,
      'start_time': startTime,
      'end_time': endTime,
      'total_price': totalPrice,
      'status': status,
      'note': note,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  // Create Booking from Map
  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      fieldId: map['field_id'] as int,
      fieldName: map['field_name'] as String,
      userName: map['user_name'] as String,
      bookingDate: map['booking_date'] as String,
      startTime: map['start_time'] as String,
      endTime: map['end_time'] as String,
      totalPrice: map['total_price'] as int,
      status: map['status'] as String? ?? 'pending',
      note: map['note'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }

  // Legacy support for old JSON format
  Map<String, dynamic> toJson() {
    return {
      'id': id?.toString() ?? '',
      'fieldId': fieldId.toString(),
      'fieldName': fieldName,
      'userName': userName,
      'date': bookingDate,
      'startTime': startTime,
      'endTime': endTime,
      'status': status,
      'createdAt':
          createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'note': note,
    };
  }

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] is String ? int.tryParse(json['id']) : json['id'],
      userId: json['userId'] is String
          ? int.parse(json['userId'])
          : json['userId'] ?? 0,
      fieldId: json['fieldId'] is String
          ? int.parse(json['fieldId'])
          : json['fieldId'],
      fieldName: json['fieldName'],
      userName: json['userName'],
      bookingDate: json['date'] is String
          ? json['date']
          : json['date'].toString(),
      startTime: json['startTime'],
      endTime: json['endTime'],
      totalPrice: json['totalPrice'] ?? 0,
      status: json['status'],
      note: json['note'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  // Helper getter for legacy support
  DateTime get date => DateTime.parse(bookingDate);

  // Create a copy with modified fields
  Booking copyWith({
    int? id,
    int? userId,
    int? fieldId,
    String? fieldName,
    String? userName,
    String? bookingDate,
    String? startTime,
    String? endTime,
    int? totalPrice,
    String? status,
    String? note,
    DateTime? createdAt,
  }) {
    return Booking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fieldId: fieldId ?? this.fieldId,
      fieldName: fieldName ?? this.fieldName,
      userName: userName ?? this.userName,
      bookingDate: bookingDate ?? this.bookingDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
