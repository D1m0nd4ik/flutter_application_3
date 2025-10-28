import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import '../models/calculation.dart';

class DatabaseHelper {
  static Future<sql.Database> database() async {
    final dbPath = await sql.getDatabasesPath();
    final pathToDb = path.join(dbPath, 'calculations.db');

    return await sql.openDatabase(
      pathToDb,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE calculations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            capital REAL NOT NULL,
            term INTEGER NOT NULL,
            rate REAL NOT NULL,
            result REAL NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  static Future<int> insertCalculation(Calculation calculation) async {
    final db = await database();
    return await db.insert('calculations', calculation.toMap());
  }

  static Future<List<Calculation>> getAllCalculations() async {
    final db = await database();
    final maps = await db.query('calculations', orderBy: 'created_at DESC');
    return List.generate(maps.length, (i) => Calculation.fromMap(maps[i]));
  }

  static Future<void> deleteAllCalculations() async {
    final db = await database();
    await db.delete('calculations');
  }
}