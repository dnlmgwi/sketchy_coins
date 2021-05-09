abstract class IAccount {
  late String? id;

  late String email;

  late String password;

  late String phoneNumber;

  late String salt;

  late String status;

  late double balance;

  late int joinedDate;

  late int? lastTrans;

  IAccount();

  Map<String, dynamic> toJson();
}
