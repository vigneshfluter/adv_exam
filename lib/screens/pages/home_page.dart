// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:af_exam/database/helper/db_helper.dart';
import 'package:af_exam/database/helper/firestore_db_helper.dart';
import 'package:af_exam/model/db_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    initializeDB();
  }

  initializeDB() async {
    await DbHelper.dbHelper.initDB();
    setState(() {});
  }

  TextEditingController nameController = TextEditingController();
  TextEditingController contactNumberController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isSelect = false;

  List selectedContacts = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
        actions: [
          (isSelect && selectedContacts.isNotEmpty)
              ? Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: MaterialButton(
                    color: Colors.green,
                    onPressed: () async {
                      await FirestoreDbHelper.firestoreDbHelper
                          .addDataInFirestore(
                        contacts: selectedContacts,
                      );
                    },
                    child: const Text("Add In Db"),
                  ),
                )
              : Container(),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: MaterialButton(
              color: Colors.blueGrey,
              onPressed: () {
                setState(() {
                  isSelect = !isSelect;
                  selectedContacts.clear();
                });
              },
              child: Text((isSelect) ? "Cancel" : "Select"),
            ),
          ),
        ],
      ),
      body: FutureBuilder(
        future: DbHelper.dbHelper.fetchData(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text("ERROR: ${snapshot.error}"),
            );
          } else if (snapshot.hasData) {
            List<DbModel>? data = snapshot.data as List<DbModel>;
            return (data.isEmpty)
                ? const Center(
                    child: Text("No Contacts available..."),
                  )
                : ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Slidable(
                          endActionPane: ActionPane(
                            motion: const ScrollMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (context) {
                                  contactNumberController.text =
                                      data[index].contactNumber;
                                  nameController.text = data[index].contactName;
                                  updateDialog(context, data, index);
                                },
                                backgroundColor: const Color(0xFF7BC043),
                                foregroundColor: Colors.white,
                                icon: Icons.update,
                                label: 'Update',
                              ),
                              SlidableAction(
                                onPressed: (context) async {
                                  deleteDialog(context, data, index);
                                },
                                backgroundColor: const Color(0xFFCB3838),
                                foregroundColor: Colors.white,
                                icon: Icons.delete,
                                label: 'Delete',
                              ),
                            ],
                          ),
                          child: ListTile(
                            tileColor: Colors.grey[200]!,
                            leading: (isSelect)
                                ? Checkbox(
                                    value: selectedContacts
                                        .contains(data[index].id),
                                    onChanged: (value) {
                                      if (selectedContacts
                                          .contains(data[index].id)) {
                                        selectedContacts.remove(data[index].id);
                                        setState(() {});
                                      } else {
                                        selectedContacts.add(data[index].id);
                                        setState(() {});
                                      }
                                    },
                                  )
                                : CircleAvatar(
                                    child: Text(data[index].id!),
                                  ),
                            title: Text(data[index].contactName),
                            subtitle:
                                Text(data[index].contactNumber.toString()),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    Uri makeCall = Uri(
                                      scheme: 'tel',
                                      path: "+91${data[index].contactNumber}",
                                    );
                                    await launchUrl(makeCall);
                                  },
                                  child: const Icon(
                                    Icons.phone,
                                    color: Colors.green,
                                  ),
                                ),
                                const SizedBox(width: 22),
                                GestureDetector(
                                  onTap: () async {
                                    Uri makeMessage = Uri(
                                      scheme: 'sms',
                                      path: "+91${data[index].contactNumber}",
                                    );
                                    await launchUrl(makeMessage);
                                  },
                                  child: const Icon(
                                    Icons.message,
                                    color: Colors.lightGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
          }
          return const Center(
            child: CircularProgressIndicator.adaptive(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          addContactDetailsDialog(context);

          setState(() {});
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<dynamic> addContactDetailsDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Contact Details..."),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Enter Contact Name",
                    contentPadding: EdgeInsets.all(10),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Please Enter Contact name & try again later...";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: contactNumberController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Enter Contact Number",
                    contentPadding: EdgeInsets.all(10),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Please Enter Contact Number & try again later...";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    MaterialButton(
                      color: Colors.red,
                      onPressed: () {
                        nameController.clear();
                        contactNumberController.clear();
                        setState(() {});
                        Navigator.pop(context);
                      },
                      child: const Text("Cancel"),
                    ),
                    const SizedBox(width: 8),
                    MaterialButton(
                      color: Colors.green,
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          int? res = await DbHelper.dbHelper.insertContact(
                            contactName: nameController.text,
                            contactNumber: contactNumberController.text,
                          );

                          nameController.clear();
                          contactNumberController.clear();
                          setState(() {});

                          if (res != null && res >= 1) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.green,
                                content:
                                    Text("Contact Inserted Succesfully..."),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.red,
                                content: Text("Contact Insertion failed..."),
                              ),
                            );
                          }
                          Navigator.pop(context);
                        }
                      },
                      child: const Text("Save"),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Future<dynamic> deleteDialog(
      BuildContext context, List<DbModel> data, int index) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Delete Contact",
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Are you sure want to Delete ${data[index].contactName}",
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MaterialButton(
                    color: Colors.red,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel"),
                  ),
                  const SizedBox(width: 8),
                  MaterialButton(
                    color: Colors.green,
                    onPressed: () async {
                      int? res = await DbHelper.dbHelper.deleteSpecificContact(
                        id: data[index].id!,
                      );

                      log(res.toString());

                      setState(() {});

                      if (res! >= 1) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.green,
                            content: Text(
                              "Contact deleted Succesfully...",
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.red,
                            content: Text(
                              "Contact deletion failed...",
                            ),
                          ),
                        );
                      }
                      Navigator.pop(context);
                    },
                    child: const Text("Yes"),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Future<dynamic> updateDialog(
      BuildContext context, List<DbModel> data, int index) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Update Contact Details..."),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Update Contact Name",
                    contentPadding: EdgeInsets.all(10),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Please Enter Contact name & try again later...";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: contactNumberController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Update Contact Number",
                    contentPadding: EdgeInsets.all(10),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Please Enter Contact Number & try again later...";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    MaterialButton(
                      color: Colors.red,
                      onPressed: () {
                        nameController.clear();
                        contactNumberController.clear();
                        setState(() {});
                        Navigator.pop(context);
                      },
                      child: const Text("Cancel"),
                    ),
                    const SizedBox(width: 8),
                    MaterialButton(
                      color: Colors.green,
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          int? res = await DbHelper.dbHelper.updateData(
                            id: data[index].id!,
                            contactName: nameController.text,
                            contactNumber: contactNumberController.text,
                          );

                          nameController.clear();
                          contactNumberController.clear();
                          setState(() {});

                          if (res != null && res >= 1) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.green,
                                content: Text("Contact Updated Succesfully..."),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.red,
                                content: Text("Contact Updation failed..."),
                              ),
                            );
                          }
                          Navigator.pop(context);
                        }
                      },
                      child: const Text("Save"),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
