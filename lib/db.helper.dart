import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'todo_item.dart';

class DBHelper {
  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'todo.db');

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE todos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        description TEXT,
        date TEXT
      )
    ''');
  }

  Future<int> insert(ToDoItem item) async {
    final db = await database;
    return await db.insert('todos', item.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<ToDoItem>> getAllTodos() async {
    final db = await database;
    final maps = await db.query('todos');
    return List.generate(maps.length, (i) => ToDoItem.fromMap(maps[i]));
  }

  Future<int> update(int id, ToDoItem item) async {
    final db = await database;
    return await db.update('todos', item.toMap(), where: 'id = ?', whereArgs: [id]);
  }

  Future<int> delete(int id) async {
    final db = await database;
    return await db.delete('todos', where: 'id = ?', whereArgs: [id]);
  }
}
