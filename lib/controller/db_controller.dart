import 'package:af_exam/database/helper/db_helper.dart';
import 'package:get/get.dart';

class DbController extends GetxController {
  Future<void> initializeDB() async {
    await DbHelper.dbHelper.initDB();
  }

  insertContactIntoDB(
      {required String contactName, required String contactNumber}) async {
    return DbHelper.dbHelper
        .insertContact(contactName: contactName, contactNumber: contactNumber);
  }

  fetchDataFromDB() async {
    return await DbHelper.dbHelper.fetchData();
  }

  deleteSpecificContactFromDB({required String id}) async {
    return DbHelper.dbHelper.deleteSpecificContact(id: id);
  }

  updateDataFromDB(
      {required String contactName,
      required String id,
      required String contactNumber}) async {
    return DbHelper.dbHelper.updateData(
        id: id, contactName: contactName, contactNumber: contactNumber);
  }
}

// Put & find