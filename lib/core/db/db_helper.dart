import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'watch_sphere.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('DROP TABLE IF EXISTS payment_history');
      await db.execute('DROP TABLE IF EXISTS alerts');
      await db.execute('DROP TABLE IF EXISTS search_history');
      await db.execute('DROP TABLE IF EXISTS saved_searches');
      await db.execute('DROP TABLE IF EXISTS bookmarks');
      await db.execute('DROP TABLE IF EXISTS invoices');
      await db.execute('DROP TABLE IF EXISTS listings');
      await db.execute('DROP TABLE IF EXISTS users');
      await _onCreate(db, newVersion);
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1. Users Table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        role TEXT NOT NULL,
        plan TEXT NOT NULL,
        status TEXT NOT NULL
      )
    ''');

    // 2. Listings Table
    await db.execute('''
      CREATE TABLE listings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        title TEXT NOT NULL,
        brand TEXT NOT NULL,
        model TEXT NOT NULL,
        price REAL NOT NULL,
        platform TEXT NOT NULL,
        year INTEGER NOT NULL,
        condition TEXT NOT NULL,
        location TEXT NOT NULL,
        is_sold INTEGER NOT NULL,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE SET NULL
      )
    ''');

    // 3. Bookmarks Table
    await db.execute('''
      CREATE TABLE bookmarks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        listing_id INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (listing_id) REFERENCES listings (id) ON DELETE CASCADE
      )
    ''');

    // 4. Saved Searches Table
    await db.execute('''
      CREATE TABLE saved_searches (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        query_text TEXT NOT NULL,
        filters_json TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // 5. Search History Table
    await db.execute('''
      CREATE TABLE search_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        query_text TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // 6. Alerts Table
    await db.execute('''
      CREATE TABLE alerts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        type TEXT NOT NULL,
        message TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        is_read INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // 7. Payment History Table
    await db.execute('''
      CREATE TABLE payment_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        plan_name TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // 8. Invoices Table
    await db.execute('''
      CREATE TABLE invoices (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        listing_id INTEGER NOT NULL,
        buyer_name TEXT NOT NULL,
        buyer_email TEXT NOT NULL,
        invoice_no TEXT NOT NULL,
        date TEXT NOT NULL,
        price REAL NOT NULL,
        FOREIGN KEY (listing_id) REFERENCES listings (id) ON DELETE CASCADE
      )
    ''');

    // Seed Initial Data
    await _seedData(db);
  }

  Future<void> _seedData(Database db) async {
    // Seed Users
    await db.rawInsert("INSERT INTO users (name, role, plan, status) VALUES ('Admin User', 'admin', 'paid', 'active')");
    await db.rawInsert("INSERT INTO users (name, role, plan, status) VALUES ('John Doe', 'user', 'free', 'active')");
    await db.rawInsert("INSERT INTO users (name, role, plan, status) VALUES ('Horology Fan', 'user', 'paid', 'active')");
    await db.rawInsert("INSERT INTO users (name, role, plan, status) VALUES ('Richard Roe', 'user', 'free', 'inactive')");

    // Seed Watch Listings
    final nowStr = DateTime.now().toIso8601String();
    
    // Rolex Submariner (124060)
    await db.rawInsert("INSERT INTO listings (user_id, title, brand, model, price, platform, year, condition, location, is_sold, timestamp) VALUES (NULL, 'Rolex Submariner 124060 41mm', 'Rolex', 'Submariner', 14800, 'Chrono24', 2023, 'New', 'USA', 0, '$nowStr')");
    await db.rawInsert("INSERT INTO listings (user_id, title, brand, model, price, platform, year, condition, location, is_sold, timestamp) VALUES (NULL, 'Rolex Submariner No Date 124060', 'Rolex', 'Submariner', 13500, 'eBay', 2021, 'Very Good', 'Germany', 0, '$nowStr')");
    await db.rawInsert("INSERT INTO listings (user_id, title, brand, model, price, platform, year, condition, location, is_sold, timestamp) VALUES (NULL, 'Rolex Submariner Ceramic 124060', 'Rolex', 'Submariner', 14100, 'Grailzee', 2022, 'Mint', 'Japan', 0, '$nowStr')");
    await db.rawInsert("INSERT INTO listings (user_id, title, brand, model, price, platform, year, condition, location, is_sold, timestamp) VALUES (NULL, 'Rolex Submariner 124060 - Steel', 'Rolex', 'Submariner', 12900, 'eBay', 2020, 'Good', 'USA', 1, '$nowStr')");
    await db.rawInsert("INSERT INTO listings (user_id, title, brand, model, price, platform, year, condition, location, is_sold, timestamp) VALUES (NULL, 'Rolex Submariner No-Date 124060', 'Rolex', 'Submariner', 15200, 'Chrono24', 2024, 'New', 'UK', 1, '$nowStr')");

    // Rolex GMT-Master II (126710BLRO)
    await db.rawInsert("INSERT INTO listings (user_id, title, brand, model, price, platform, year, condition, location, is_sold, timestamp) VALUES (NULL, 'Rolex GMT-Master II Pepsi 126710BLRO', 'Rolex', 'GMT-Master II', 22500, 'Chrono24', 2023, 'Mint', 'Switzerland', 0, '$nowStr')");
    await db.rawInsert("INSERT INTO listings (user_id, title, brand, model, price, platform, year, condition, location, is_sold, timestamp) VALUES (NULL, 'Rolex GMT Pepsi Steel 126710BLRO', 'Rolex', 'GMT-Master II', 21900, 'eBay', 2021, 'Very Good', 'USA', 0, '$nowStr')");
    await db.rawInsert("INSERT INTO listings (user_id, title, brand, model, price, platform, year, condition, location, is_sold, timestamp) VALUES (NULL, 'Rolex GMT Master II Pepsi Jubilee', 'Rolex', 'GMT-Master II', 23200, 'Grailzee', 2022, 'New', 'Hong Kong', 0, '$nowStr')");
    await db.rawInsert("INSERT INTO listings (user_id, title, brand, model, price, platform, year, condition, location, is_sold, timestamp) VALUES (NULL, 'Rolex GMT-Master II Pepsi 126710', 'Rolex', 'GMT-Master II', 20800, 'eBay', 2019, 'Good', 'UK', 1, '$nowStr')");

    // Omega Speedmaster Professional Moonwatch
    await db.rawInsert("INSERT INTO listings (user_id, title, brand, model, price, platform, year, condition, location, is_sold, timestamp) VALUES (NULL, 'Omega Speedmaster Moonwatch Hesalite', 'Omega', 'Speedmaster', 7600, 'Chrono24', 2023, 'New', 'USA', 0, '$nowStr')");
    await db.rawInsert("INSERT INTO listings (user_id, title, brand, model, price, platform, year, condition, location, is_sold, timestamp) VALUES (NULL, 'Omega Speedmaster Professional 310.30', 'Omega', 'Speedmaster', 6950, 'eBay', 2022, 'Mint', 'Japan', 0, '$nowStr')");
    await db.rawInsert("INSERT INTO listings (user_id, title, brand, model, price, platform, year, condition, location, is_sold, timestamp) VALUES (NULL, 'Omega Speedmaster Co-Axial Master Chronometer', 'Omega', 'Speedmaster', 7200, 'Grailzee', 2021, 'Very Good', 'Germany', 0, '$nowStr')");
    await db.rawInsert("INSERT INTO listings (user_id, title, brand, model, price, platform, year, condition, location, is_sold, timestamp) VALUES (NULL, 'Omega Speedmaster Professional 3861', 'Omega', 'Speedmaster', 6100, 'eBay', 2020, 'Good', 'USA', 1, '$nowStr')");

    // Patek Philippe Nautilus (5711)
    await db.rawInsert("INSERT INTO listings (user_id, title, brand, model, price, platform, year, condition, location, is_sold, timestamp) VALUES (NULL, 'Patek Philippe Nautilus Blue Dial 5711/1A-010', 'Patek Philippe', 'Nautilus', 119000, 'Chrono24', 2018, 'Very Good', 'UAE', 0, '$nowStr')");
    await db.rawInsert("INSERT INTO listings (user_id, title, brand, model, price, platform, year, condition, location, is_sold, timestamp) VALUES (NULL, 'Patek Philippe Nautilus Steel 5711/1A', 'Patek Philippe', 'Nautilus', 112000, 'Grailzee', 2017, 'Mint', 'Switzerland', 0, '$nowStr')");
    await db.rawInsert("INSERT INTO listings (user_id, title, brand, model, price, platform, year, condition, location, is_sold, timestamp) VALUES (NULL, 'Patek Philippe 5711 Nautilus Steel Blue', 'Patek Philippe', 'Nautilus', 98000, 'eBay', 2015, 'Good', 'USA', 1, '$nowStr')");

    // Audemars Piguet Royal Oak (15500ST)
    await db.rawInsert("INSERT INTO listings (user_id, title, brand, model, price, platform, year, condition, location, is_sold, timestamp) VALUES (NULL, 'Audemars Piguet Royal Oak Blue Dial 15500ST', 'Audemars Piguet', 'Royal Oak', 38500, 'Chrono24', 2021, 'Mint', 'USA', 0, '$nowStr')");
    await db.rawInsert("INSERT INTO listings (user_id, title, brand, model, price, platform, year, condition, location, is_sold, timestamp) VALUES (NULL, 'Audemars Piguet Royal Oak 15500ST Black', 'Audemars Piguet', 'Royal Oak', 36200, 'eBay', 2020, 'Very Good', 'UK', 0, '$nowStr')");
    await db.rawInsert("INSERT INTO listings (user_id, title, brand, model, price, platform, year, condition, location, is_sold, timestamp) VALUES (NULL, 'Audemars Piguet Royal Oak 41mm 15500ST', 'Audemars Piguet', 'Royal Oak', 37100, 'Grailzee', 2022, 'New', 'Singapore', 0, '$nowStr')");
    await db.rawInsert("INSERT INTO listings (user_id, title, brand, model, price, platform, year, condition, location, is_sold, timestamp) VALUES (NULL, 'Audemars Piguet Royal Oak 15500ST Grey', 'Audemars Piguet', 'Royal Oak', 34500, 'eBay', 2019, 'Good', 'USA', 1, '$nowStr')");

    // Seed Trader In-App Listings (by Horology Fan, user_id = 3)
    await db.rawInsert("INSERT INTO listings (user_id, title, brand, model, price, platform, year, condition, location, is_sold, timestamp) VALUES (3, 'Rolex Daytona White Dial 116500LN', 'Rolex', 'Daytona', 31500, 'In-App', 2022, 'Mint', 'USA', 0, '$nowStr')");
    await db.rawInsert("INSERT INTO listings (user_id, title, brand, model, price, platform, year, condition, location, is_sold, timestamp) VALUES (3, 'Omega Seamaster Diver 300M Blue', 'Omega', 'Seamaster', 5200, 'In-App', 2021, 'Very Good', 'UK', 0, '$nowStr')");
    await db.rawInsert("INSERT INTO listings (user_id, title, brand, model, price, platform, year, condition, location, is_sold, timestamp) VALUES (3, 'Cartier Santos de Cartier Large Steel', 'Cartier', 'Santos', 7400, 'In-App', 2023, 'New', 'Canada', 0, '$nowStr')");
    await db.rawInsert("INSERT INTO listings (user_id, title, brand, model, price, platform, year, condition, location, is_sold, timestamp) VALUES (3, 'Rolex Explorer II Polar Dial 226570', 'Rolex', 'Explorer II', 11800, 'In-App', 2023, 'Mint', 'USA', 1, '$nowStr')");

    // Seed initial alerts
    await db.rawInsert("INSERT INTO alerts (user_id, type, message, timestamp, is_read) VALUES (2, 'new_listing', 'New Listing Alert: Rolex Submariner 124060 posted on Grailzee for \$14,100', '$nowStr', 0)");
    await db.rawInsert("INSERT INTO alerts (user_id, type, message, timestamp, is_read) VALUES (2, 'price_drop', 'Price Drop: Omega Speedmaster Hesalite on Chrono24 dropped from \$7,900 to \$7,600', '$nowStr', 0)");
    await db.rawInsert("INSERT INTO alerts (user_id, type, message, timestamp, is_read) VALUES (3, 'price_drop', 'Price Drop: Patek Philippe Nautilus on Grailzee dropped from \$115,000 to \$112,000', '$nowStr', 0)");

    // Seed initial payment history
    await db.rawInsert("INSERT INTO payment_history (user_id, amount, date, plan_name) VALUES (3, 29.99, '2026-05-15', 'paid')");
    await db.rawInsert("INSERT INTO payment_history (user_id, amount, date, plan_name) VALUES (3, 29.99, '2026-06-15', 'paid')");
  }
}
