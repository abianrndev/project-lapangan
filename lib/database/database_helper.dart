import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/field.dart';
import '../models/booking.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    _database ??= await _createDB();
    return _database!;
  }

  Future<Database> _createDB() async {
    String path = join(await getDatabasesPath(), 'sport_field. db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        // Users table
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL,
            phone TEXT,
            role TEXT NOT NULL DEFAULT 'user',
            created_at TEXT DEFAULT CURRENT_TIMESTAMP
          )
        ''');

        // Fields table
        await db.execute('''
        CREATE TABLE fields (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          description TEXT NOT NULL,
          price_per_hour INTEGER NOT NULL,
          image_url TEXT,
          is_available INTEGER NOT NULL DEFAULT 1,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP
        )
      ''');

        // Bookings table
        await db.execute('''
        CREATE TABLE bookings (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          field_id INTEGER NOT NULL,
          booking_date TEXT NOT NULL,
          start_time TEXT NOT NULL,
          end_time TEXT NOT NULL,
          total_price INTEGER NOT NULL,
          status TEXT NOT NULL DEFAULT 'pending',
          note TEXT,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (user_id) REFERENCES users (id),
          FOREIGN KEY (field_id) REFERENCES fields (id)
        )
      ''');

        // Revenue table
        await db.execute('''
        CREATE TABLE daily_revenue (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT NOT NULL,
          amount INTEGER NOT NULL,
          booking_id INTEGER,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (booking_id) REFERENCES bookings (id)
        )
      ''');

        // Insert default admin
        await db.insert('users', {
          'name': 'Admin',
          'email': 'admin@lapangan.com',
          'password': 'admin123',
          'phone': null,
          'role': 'admin',
        });

        // Insert sample fields
        await db.insert('fields', {
          'name': 'Lapangan A',
          'description':
              'Lapangan futsal dengan kualitas rumput sintetis terbaik',
          'price_per_hour': 100000,
          'image_url': '',
          'is_available': 1,
        });

        await db.insert('fields', {
          'name': 'Lapangan B',
          'description': 'Lapangan indoor ber-AC dengan fasilitas lengkap',
          'price_per_hour': 150000,
          'image_url': '',
          'is_available': 1,
        });
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // ✅ ADD migration untuk existing database
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE users ADD COLUMN phone TEXT');
        }
      },
    );
  }

  // ===== USER METHODS =====
  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return results.isNotEmpty ? User.fromMap(results.first) : null;
  }

  // ✅ ADD:  Get user by ID
  Future<User?> getUserById(int id) async {
    final db = await database;
    final results = await db.query('users', where: 'id = ?', whereArgs: [id]);
    return results.isNotEmpty ? User.fromMap(results.first) : null;
  }

  Future<int> createUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  // ✅ ADD: Update user
  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // ===== FIELD METHODS =====
  Future<List<Field>> getAllFields() async {
    final db = await database;
    final results = await db.query('fields', orderBy: 'created_at DESC');
    return results.map((map) => Field.fromMap(map)).toList();
  }

  // ✅ ADD: Get available fields only
  Future<List<Field>> getAvailableFields() async {
    final db = await database;
    final results = await db.query(
      'fields',
      where: 'is_available = ? ',
      whereArgs: [1],
      orderBy: 'created_at DESC',
    );
    return results.map((map) => Field.fromMap(map)).toList();
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
    return await db.delete('fields', where: 'id = ?', whereArgs: [id]);
  }

  // ===== BOOKING METHODS =====
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
      INNER JOIN fields f ON b. field_id = f.id
      ORDER BY b.created_at DESC
    ''');
    return results.map((map) => Booking.fromMap(map)).toList();
  }

  Future<List<Booking>> getBookingsByUserId(int userId) async {
    final db = await database;
    final results = await db.rawQuery(
      '''
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
    ''',
      [userId],
    );
    return results.map((map) => Booking.fromMap(map)).toList();
  }

  // ✅ ADD: Get bookings by field ID
  Future<List<Booking>> getBookingsByFieldId(int fieldId) async {
    final db = await database;
    final results = await db.rawQuery(
      '''
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
    ''',
      [fieldId],
    );
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
    return await db.delete('bookings', where: 'id = ?', whereArgs: [id]);
  }

  Future<bool> hasBookingConflict(
    int fieldId,
    String bookingDate,
    String startTime,
    String endTime, {
    int? excludeBookingId,
  }) async {
    final db = await database;

    String query = '''
      SELECT COUNT(*) as count FROM bookings 
      WHERE field_id = ? AND booking_date = ? AND status IN ('pending', 'confirmed')
      AND ((start_time < ? AND end_time > ?) OR (start_time < ? AND end_time > ?) OR (start_time >= ? AND start_time < ?) OR (end_time > ?  AND end_time <= ?))
    ''';

    List<dynamic> params = [
      fieldId,
      bookingDate,
      startTime,
      startTime,
      endTime,
      endTime,
      startTime,
      endTime,
      startTime,
      endTime,
    ];

    if (excludeBookingId != null) {
      query += ' AND id != ?';
      params.add(excludeBookingId);
    }

    final result = await db.rawQuery(query, params);
    return (result.first['count'] as int) > 0;
  }

  // ===== REVENUE METHODS =====
  Future<void> addTodaysRevenue(int amount, {int? bookingId}) async {
    final db = await database;
    final today = DateTime.now().toIso8601String().split('T')[0];
    await db.insert('daily_revenue', {
      'date': today,
      'amount': amount,
      'booking_id': bookingId,
    });
  }

  Future<int> getTodaysRevenue() async {
    final db = await database;
    final today = DateTime.now().toIso8601String().split('T')[0];
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM daily_revenue WHERE date = ? ',
      [today],
    );
    return (result.first['total'] as int?) ?? 0;
  }

  // ===== DASHBOARD STATS =====
  Future<Map<String, dynamic>> getDashboardStats() async {
    final db = await database;

    final totalBookingsResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM bookings',
    );
    final totalBookings = totalBookingsResult.first['count'] as int;

    final activeFieldsResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM fields WHERE is_available = 1',
    );
    final activeFields = activeFieldsResult.first['count'] as int;

    final todayRevenue = await getTodaysRevenue();

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
}
