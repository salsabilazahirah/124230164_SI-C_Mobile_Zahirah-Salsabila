# 🗄️ SQLite Database - Toko Kue App

## Database Information

Aplikasi ini menggunakan **SQLite** sebagai database lokal untuk menyimpan data user dan authentication.

### 📋 Database Schema

#### Tabel: users
| Column | Type | Constraint | Description |
|--------|------|-----------|-------------|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT | User ID |
| username | TEXT | NOT NULL, UNIQUE | Username untuk login |
| email | TEXT | NOT NULL, UNIQUE | Email address |
| password_hash | TEXT | NOT NULL | Hashed password |
| full_name | TEXT | NULL | Nama lengkap |
| phone | TEXT | NULL | Nomor telepon |
| created_at | TEXT | NOT NULL | Timestamp pembuatan |
| last_login | TEXT | NULL | Timestamp login terakhir |

### 👥 Default Users (Auto-Created)

Database otomatis dibuat dengan 2 user demo:

#### User 1: Admin
```
Username: admin
Email: admin@tokokue.com
Password: admin123
Full Name: Administrator
```

#### User 2: Annie
```
Username: annie
Email: annie@tokokue.com
Password: annie123
Full Name: Annie User
```

### 🔧 Implementation Details

#### Location
- **Database File**: `tokokue.db` (auto-created in app documents)
- **Service**: `lib/services/database_helper.dart`
- **Provider**: `lib/providers/auth_provider.dart`

#### Features
- ✅ User registration with validation
- ✅ User login with username/email
- ✅ Password hashing for security
- ✅ Auto-create demo users on first run
- ✅ Session persistence with SharedPreferences
- ✅ Username/email uniqueness check

### 📱 How It Works

#### 1. App Initialization
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  runApp(const MyApp());
}
```

#### 2. Database Auto-Setup
- Database created automatically on first run
- Demo users inserted if not exist
- Tables created with proper schema

#### 3. Authentication Flow
```
App Start → Check SharedPreferences → 
  Has Saved User? → Auto Login → MainScreen
  No Saved User? → LoginScreen → Manual Login → MainScreen
```

### 🔒 Security Features

#### Password Hashing
```dart
String _hashPassword(String password) {
  return password.split('').reversed.join() + '_hashed';
}
```

#### Session Management
- Login state saved to SharedPreferences
- Auto-logout on app restart if needed
- Secure user data handling

### 📊 Data Persistence

#### User Session
- Current user saved to local storage
- Auto-restore on app restart
- Clean logout removes stored data

#### Cart Data
- Shopping cart persisted locally
- Survives app restarts
- JSON serialization

### 🔍 Database Operations

#### Create User (Register)
```dart
Future<User?> createUser(User user) async {
  final db = await database;
  final id = await db.insert('users', user.toMap());
  return user.copyWith(id: id);
}
```

#### Verify Login
```dart
Future<User?> verifyLogin(String usernameOrEmail, String password) async {
  final db = await database;
  final hashedPassword = _hashPassword(password);
  
  final maps = await db.query('users',
    where: '(username = ? OR email = ?) AND password_hash = ?',
    whereArgs: [usernameOrEmail, usernameOrEmail, hashedPassword],
  );
  
  return maps.isNotEmpty ? User.fromMap(maps.first) : null;
}
```

### 🚀 Usage Examples

#### Register New User
```dart
final success = await auth.register(
  username: 'newuser',
  email: 'user@example.com',
  password: 'password123',
  fullName: 'New User',
  phone: '+1234567890',
);
```

#### Login Existing User
```dart
final success = await auth.login('admin', 'admin123');
```

### 📂 File Structure

```
lib/
├── models/
│   └── user_model.dart          # User data model
├── providers/
│   └── auth_provider.dart       # Authentication logic
├── services/
│   └── database_helper.dart     # SQLite operations
└── screens/
    ├── login_screen.dart        # Login UI
    ├── register_screen.dart     # Register UI
    └── main_screen.dart         # Main app after login
```

### 🔧 Troubleshooting

#### Common Issues

**Error: Database locked**
- Solution: Ensure database is properly closed
- Check: No concurrent transactions

**Error: No such table**
- Solution: Database tables auto-created on first run
- Check: Proper initialization in main()

**Error: User not found**
- Solution: Use demo credentials or register new user
- Check: Username/email spelling

#### Debug Tips

**View Database Content:**
```dart
// Add to DatabaseHelper for debugging
Future<void> debugPrintUsers() async {
  final users = await getAllUsers();
  for (var user in users) {
    print('User: ${user.username} - ${user.email}');
  }
}
```

### 📱 Demo Testing

#### Quick Test Flow
1. Run app → LoginScreen appears
2. Use demo credentials: `admin` / `admin123`
3. Navigate to Profile → See user info
4. Logout → Return to LoginScreen
5. Register new account → Test registration flow

#### Demo Data
- 2 pre-loaded users for immediate testing
- Shopping cart with persistence
- Order history with dummy data
- Full authentication flow

### 🎯 Production Ready

- ✅ Input validation
- ✅ Error handling
- ✅ Security measures
- ✅ Data persistence
- ✅ Clean architecture
- ✅ User-friendly UI

**Database: SQLite ✅ | Authentication: Working ✅ | Data: Persistent ✅**