# BOOKING LAPANGAN APP

Sebuah aplikasi booking lapangan olahraga dengan sistem database SQLite, autentikasi pengguna, dan manajemen booking lengkap.

## Fitur Utama

### Untuk Pengguna
- **Registrasi & Login**: Sistem autentikasi aman dengan password terenkripsi
- **Lihat Lapangan**: Daftar lapangan yang tersedia dengan gambar dan deskripsi
- **Booking Lapangan**: Sistem booking dengan pemilihan tanggal dan waktu
- **Deteksi Konflik**: Otomatis mencegah double booking
- **Riwayat Booking**: Lihat semua booking yang pernah dilakukan
- **Profil**: Kelola informasi profil pengguna
- **WhatsApp Integration**: Chat langsung dengan admin untuk booking cepat

### Untuk Admin
- **Dashboard**: Statistik real-time dari database
- **Kelola Lapangan**: CRUD lengkap untuk data lapangan
- **Kelola Booking**: Konfirmasi, tolak, atau selesaikan booking
- **Statistik**: Total booking, lapangan aktif, pendapatan, dan pengguna aktif

## Teknologi

- **Flutter**: Framework UI cross-platform
- **SQLite**: Database lokal untuk penyimpanan data
- **Provider**: State management
- **GoRouter**: Routing dan navigasi
- **Crypto**: Enkripsi password dengan SHA-256
- **Intl**: Format mata uang dan tanggal

## Database Schema

### Users Table
```sql
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL,
  phone TEXT,
  role TEXT DEFAULT 'user',
  created_at TEXT DEFAULT CURRENT_TIMESTAMP
);
```

### Fields Table
```sql
CREATE TABLE fields (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  description TEXT,
  price_per_hour INTEGER NOT NULL,
  image_url TEXT,
  is_available INTEGER DEFAULT 1,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP
);
```

### Bookings Table
```sql
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
);
```

## Getting Started

### Prerequisites
- Flutter SDK (3.9.2 atau lebih baru)
- Dart SDK
- Android Studio / VS Code dengan Flutter plugin

### Installation

1. Clone repository
```bash
git clone https://github.com/abianrndev/project-lapangan.git
cd project-lapangan
```

2. Install dependencies
```bash
flutter pub get
```

3. Run aplikasi
```bash
flutter run
```

## Demo Credentials

### Admin
- Email: `admin@lapangan.com`
- Password: `admin123`

### User
- Email: `user@test.com`
- Password: `user123`

## Struktur Project

```
lib/
├── database/
│   └── database_helper.dart         # SQLite database operations
├── models/
│   ├── user.dart                    # User model
│   ├── field.dart                   # Field model
│   └── booking.dart                 # Booking model
├── providers/
│   ├── auth_provider.dart           # Authentication state
│   ├── field_provider.dart          # Field management
│   └── booking_provider.dart        # Booking management
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart        # Login page
│   │   └── register_screen.dart     # Registration page
│   ├── admin/
│   │   ├── admin_dashboard.dart     # Admin dashboard
│   │   ├── field_management.dart    # Manage fields
│   │   └── booking_management.dart  # Manage bookings
│   └── user/
│       ├── user_home.dart           # User home page
│       ├── profile_screen.dart      # User profile
│       └── booking_history_screen.dart  # Booking history
├── widgets/
│   └── ...                          # Reusable widgets
├── constants/
│   ├── colors.dart                  # App colors
│   └── text_styles.dart             # Text styles
└── main.dart                        # App entry point
```

## Fitur Keamanan

- ✅ Password dienkripsi dengan SHA-256
- ✅ Input validation di semua form
- ✅ Deteksi konflik booking otomatis
- ✅ Session management untuk auth state
- ✅ Error handling comprehensive

## Roadmap

- [ ] Push notifications untuk booking
- [ ] Payment gateway integration
- [ ] Rating & review system
- [ ] Field availability calendar
- [ ] Export laporan ke PDF
- [ ] Multi-language support

## Screenshots

<img width="505" height="658" alt="image" src="https://github.com/user-attachments/assets/ea0838cb-b8ba-4347-a4f9-c958d4fec78a" />
<img width="501" height="647" alt="image" src="https://github.com/user-attachments/assets/fc687e1f-afba-4b33-93a1-34e8c9a3c26e" />
<img width="501" height="653" alt="image" src="https://github.com/user-attachments/assets/6149434f-c0e5-4a59-b18c-30c17bbbeb8d" />
<img width="501" height="642" alt="image" src="https://github.com/user-attachments/assets/58b0ac1d-6a62-4862-b36f-e7c3e4ebc91f" />

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License.

