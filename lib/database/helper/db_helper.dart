import 'dart:developer';

import 'package:af_exam/model/db_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  DbHelper._();
  static DbHelper dbHelper = DbHelper._();
  String contacts = "Contacts";

  Database? database;

  initDB() async {
    database = null;
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, "contacts.db");
    database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        String query =
            "CREATE TABLE IF NOT EXISTS $contacts (ID INTEGER PRIMARY KEY, contactNumber TEXT NOT NULL, contactName TEXT NOT NULL)";
        await db.execute(query);
        log("Database created Succesfully...");
      },
    );
  }

  Future<int?> insertContact(
      {required String contactName, required String contactNumber}) async {
    if (database != null) {
      List args = [contactNumber, contactName];
      String query =
          "INSERT INTO $contacts (contactNumber, contactName) VALUES (?,?)";
      log("Data Inserted Succesfully...");
      return database?.rawInsert(query, args);
    } else {
      initDB();
    }
    return null;
  }

  fetchData() async {
    if (database != null) {
      String query = "SELECT * FROM $contacts";
      List<Map> data = await database?.rawQuery(query) as List<Map>;
      List<DbModel> output = data.map((e) => DbModel.fromMap(data: e)).toList();
      return output;
    } else {
      initDB();
    }
    return null;
  }

  deleteSpecificContact({required String id}) async {
    if (database != null) {
      List args = [id];
      String query = "DELETE FROM $contacts WHERE ID = ?";
      return database?.rawDelete(query, args);
    } else {
      initDB();
    }
  }

  updateData(
      {required String id,
      required String contactName,
      required String contactNumber}) async {
    if (database != null) {
      List args = [contactName, contactNumber, id];
      String query =
          "UPDATE $contacts SET contactName = ?, contactNumber = ? WHERE ID = ?";
      return database?.rawUpdate(query, args);
    } else {
      initDB();
    }
  }

  fetchSpecificData({required String id}) async {
    if (database != null) {
      List args = [id];
      String query = "SELECT * FROM $contacts WHERE ID = ?";
      List<Map>? res = await database?.rawQuery(query, args) as List<Map>;
      return res;
    } else {
      initDB();
    }
  }
}
