class DbModel {
  String contactName;
  String contactNumber;
  String? id;

  DbModel({
    required this.contactName,
    required this.contactNumber,
    this.id,
  });

  factory DbModel.fromMap({required Map data}) {
    return DbModel(
      id: data['ID'].toString(),
      contactName: data['contactName'].toString(),
      contactNumber: data['contactNumber'].toString(),
    );
  }
}
