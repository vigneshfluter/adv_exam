import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreDbHelper {
  FirestoreDbHelper._();
  static FirestoreDbHelper firestoreDbHelper = FirestoreDbHelper._();

  FirebaseFirestore db = FirebaseFirestore.instance;

  addDataInFirestore({required List contacts}) async {
    // List allContacts = [];

    await db.collection("Contacts").doc().set({"details": contacts});

    // List.generate(
    //   contacts.length,
    //   (index) async {
    //     await db.collection("Contacts").doc().set({"details": contacts[index]});
    //     log(contacts[index].toString());
    //   },
    // );
  }
}
