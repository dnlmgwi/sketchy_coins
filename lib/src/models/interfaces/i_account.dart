abstract class IAccount {
  String? id;

  late String password;

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
