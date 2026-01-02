import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/field.dart';
import '../models/booking.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('booking_lapangan.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        phone TEXT,
        role TEXT DEFAULT 'user',
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Fields table
    await db.execute('''
      CREATE TABLE fields (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        price_per_hour INTEGER NOT NULL,
        image_url TEXT,
        is_available INTEGER DEFAULT 1,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Bookings table
    await db.execute('''
      CREATE TABLE bookings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        field_id INTEGER,
        booking_date TEXT NOT NULL,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        total_price INTEGER NOT NULL,
        status TEXT DEFAULT 'pending',
        note TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (field_id) REFERENCES fields (id)
      )
    ''');

    // Insert default admin user
    await db.insert('users', {
      'name': 'Admin',
      'email': 'admin@lapangan.com',
      'password': 'admin123', // In production, this should be hashed
      'phone': '08123456789',
      'role': 'admin',
    });

    // Insert default user
    await db.insert('users', {
      'name': 'User Test',
      'email': 'user@test.com',
      'password': 'user123',
      'phone': '08123456789',
      'role': 'user',
    });

    // Insert sample fields
    await db.insert('fields', {
      'name': 'Lapangan A',
      'description': 'Lapangan futsal indoor dengan rumput sintetis berkualitas',
      'price_per_hour': 150000,
      'image_url': 'https://picsum.photos/400/300?random=1',
      'is_available': 1,
    });

    await db.insert('fields', {
      'name': 'Lapangan B',
      'description': 'Lapangan basket indoor dengan lantai vinyl',
      'price_per_hour': 200000,
      'image_url': 'https://picsum.photos/400/300?random=2',
      'is_available': 1,
    });

    await db.insert('fields', {
      'name': 'Lapangan C',
      'description': 'Lapangan badminton indoor dengan pencahayaan optimal',
      'price_per_hour': 100000,
      'image_url': 'https://picsum.photos/400/300?random=3',
      'is_available': 1,
    });
  }

  // User CRUD operations
  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (results.isEmpty) return null;
    return User.fromMap(results.first);
  }

  Future<User?> getUserById(int id) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isEmpty) return null;
    return User.fromMap(results.first);
  }

  Future<int> createUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // Field CRUD operations
  Future<List<Field>> getAllFields() async {
    final db = await database;
    final results = await db.query('fields', orderBy: 'created_at DESC');
    return results.map((map) => Field.fromMap(map)).toList();
  }

  Future<List<Field>> getAvailableFields() async {
    final db = await database;
    final results = await db.query(
      'fields',
      where: 'is_available = ?',
      whereArgs: [1],
      orderBy: 'created_at DESC',
    );
    return results.map((map) => Field.fromMap(map)).toList();
  }

  Future<Field?> getFieldById(int id) async {
    final db = await database;
    final results = await db.query(
      'fields',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isEmpty) return null;
    return Field.fromMap(results.first);
  }

  Future<int> createField(Field field) async {
    final db = await database;
    return await db.insert('fields', field.toMap());
  }

  Future<int> updateField(Field field) async {
    final db = await database;
    return await db.update(
      'fields',
      field.toMap(),
      where: 'id = ?',
      whereArgs: [field.id],
    );
  }

  Future<int> deleteField(int id) async {
    final db = await database;
    return await db.delete(
      'fields',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Booking CRUD operations
  Future<List<Booking>> getAllBookings() async {
    final db = await database;
    final results = await db.rawQuery('''
      SELECT 
        b.*,
        u.name as user_name,
        f.name as field_name,
        f.price_per_hour
      FROM bookings b
      INNER JOIN users u ON b.user_id = u.id
      INNER JOIN fields f ON b.field_id = f.id
      ORDER BY b.created_at DESC
    ''');
    return results.map((map) => Booking.fromMap(map)).toList();
  }

  Future<List<Booking>> getBookingsByUserId(int userId) async {
    final db = await database;
    final results = await db.rawQuery('''
      SELECT 
        b.*,
        u.name as user_name,
        f.name as field_name,
        f.price_per_hour
      FROM bookings b
      INNER JOIN users u ON b.user_id = u.id
      INNER JOIN fields f ON b.field_id = f.id
      WHERE b.user_id = ?
      ORDER BY b.created_at DESC
    ''', [userId]);
    return results.map((map) => Booking.fromMap(map)).toList();
  }

  Future<List<Booking>> getBookingsByFieldId(int fieldId) async {
    final db = await database;
    final results = await db.rawQuery('''
      SELECT 
        b.*,
        u.name as user_name,
        f.name as field_name,
        f.price_per_hour
      FROM bookings b
      INNER JOIN users u ON b.user_id = u.id
      INNER JOIN fields f ON b.field_id = f.id
      WHERE b.field_id = ?
      ORDER BY b.created_at DESC
    ''', [fieldId]);
    return results.map((map) => Booking.fromMap(map)).toList();
  }

  Future<int> createBooking(Booking booking) async {
    final db = await database;
    return await db.insert('bookings', booking.toMap());
  }

  Future<int> updateBookingStatus(int id, String status) async {
    final db = await database;
    return await db.update(
      'bookings',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteBooking(int id) async {
    final db = await database;
    return await db.delete(
      'bookings',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Statistics for admin dashboard
  Future<Map<String, dynamic>> getDashboardStats() async {
    final db = await database;

    // Total bookings
    final totalBookingsResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM bookings',
    );
    final totalBookings = totalBookingsResult.first['count'] as int;

    // Active fields
    final activeFieldsResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM fields WHERE is_available = 1',
    );
    final activeFields = activeFieldsResult.first['count'] as int;

    // Today's revenue
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final todayRevenueResult = await db.rawQuery(
      'SELECT SUM(total_price) as total FROM bookings WHERE booking_date = ? AND status = "confirmed"',
      [todayStr],
    );
    final todayRevenue = todayRevenueResult.first['total'] ?? 0;

    // Active users (users with at least one booking)
    final activeUsersResult = await db.rawQuery(
      'SELECT COUNT(DISTINCT user_id) as count FROM bookings',
    );
    final activeUsers = activeUsersResult.first['count'] as int;

    return {
      'totalBookings': totalBookings,
      'activeFields': activeFields,
      'todayRevenue': todayRevenue,
      'activeUsers': activeUsers,
    };
  }

  // Check for booking conflicts
  Future<bool> hasBookingConflict(
    int fieldId,
    String bookingDate,
    String startTime,
    String endTime,
    {int? excludeBookingId}
  ) async {
    final db = await database;
    
    String query = '''
      SELECT COUNT(*) as count FROM bookings 
      WHERE field_id = ? 
      AND booking_date = ? 
      AND status != 'rejected' 
      AND status != 'cancelled'
      AND (
        (start_time < ? AND end_time > ?)
        OR (start_time < ? AND end_time > ?)
        OR (start_time >= ? AND end_time <= ?)
      )
    ''';
    
    List<dynamic> args = [
      fieldId,
      bookingDate,
      endTime, startTime,
      endTime, startTime,
      startTime, endTime,
    ];

    if (excludeBookingId != null) {
      query += ' AND id != ?';
      args.add(excludeBookingId);
    }

    final result = await db.rawQuery(query, args);
    final count = result.first['count'] as int;
    return count > 0;
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
