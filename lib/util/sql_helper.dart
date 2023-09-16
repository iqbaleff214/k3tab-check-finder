import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {
  static Future<sql.Database> db() async {
    return sql.openDatabase(
      "k3tab2023.db", version: 1,
      onCreate: (db, version) async => await migrate(db)
    );
  }

  static Future<void> migrate(sql.Database db) async {
    await db.execute("""
        CREATE TABLE lists (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          path TEXT NULL,
          progress DOUBLE DEFAULT 0.0,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
        )
    """);
    await db.execute("""
        CREATE TABLE items (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          item_number INTEGER,
          part_number TEXT,
          job_description TEXT,
          status TEXT,
          list_id INTEGER,
          quantity INTEGER DEFAULT 0,
          checked INTEGER DEFAULT 0,
          note TEXT,
          FOREIGN KEY (list_id) REFERENCES lists(id)
        )
    """);
  }
}
