abstract class IAccount {
  String? id;

  late String pin;

  late String phoneNumber;

  late int? locationId;

  late String salt;

  late String status;

  late int balance;

  late int joinedDate;

  int? lastTrans;

  late String gender;

  late int age;

  Map<String, dynamic> toJson();
}
