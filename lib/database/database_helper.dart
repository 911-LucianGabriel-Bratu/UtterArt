import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'images_db.db');
    return await openDatabase(path, version: 1, onCreate: _createDb);
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE images(id INTEGER PRIMARY KEY AUTOINCREMENT, image_name TEXT, prediction_text TEXT)');
  }

  Future<void> insertImage(String imageName, String predictionText) async {
    final Database db = await database;
    await db.insert(
      'images',
      {'image_name': imageName, 'prediction_text': predictionText},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getImages() async {
    final Database db = await database;
    return await db.query('images');
  }
}

Future<void> saveImageAndInsertIntoDb(String imageBytes, String predictionText) async {
  try {
    String imageName = await saveImageInDownloadsDirectory(imageBytes);
    await DatabaseHelper().insertImage(imageName, predictionText);
  } catch (e) {
    print('Failed to save image locally and insert into database: $e');
  }
}

Future<String> saveImageInDownloadsDirectory(String imageBytes) async {
  try {
    Directory? downloadsDirectory = await getExternalStorageDirectory();
    if (downloadsDirectory != null) {
      String downloadsPath = downloadsDirectory.path;
      int nextId = await getNextIdFromDatabase();
      String imageName = 'image$nextId.jpg';

      final File file = File('$downloadsPath/$imageName');
      await file.writeAsBytes(base64Decode(imageBytes));
      print('Image saved in downloads directory: ${file.path}');
      return imageName;
    } else {
      throw 'Downloads directory not found.';
    }
  } catch (e) {
    print('Failed to save image in downloads directory: $e');
    rethrow;
  }
}

Future<int> getNextIdFromDatabase() async {
  final Database db = await DatabaseHelper().database;
  List<Map<String, dynamic>> result = await db.rawQuery('SELECT MAX(id) AS max_id FROM images');
  if (result.isNotEmpty && result.first['max_id'] != null) {
    int maxId = result.first['max_id'] as int;
    return maxId + 1;
  } else {
    return 1;
  }
}