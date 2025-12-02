class Booking {
  final String id;
  final String fieldId;
  final String fieldName;
  final String userName;
  final DateTime date; // tanggal booking
  final String startTime; // contoh: "14:00"
  final String endTime; // contoh: "16:00"
  String status; // Pending, Confirmed, Rejected, Completed
  final DateTime createdAt;
  final String? note;

  Booking({
    required this.id,
    required this.fieldId,
    required this.fieldName,
    required this.userName,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.status = 'Pending',
    DateTime? createdAt,
    this.note,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fieldId': fieldId,
      'fieldName': fieldName,
      'userName': userName,
      'date': date.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'note': note,
    };
  }

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      fieldId: json['fieldId'],
      fieldName: json['fieldName'],
      userName: json['userName'],
      date: DateTime.parse(json['date']),
      startTime: json['startTime'],
      endTime: json['endTime'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      note: json['note'],
    );
  }
}
