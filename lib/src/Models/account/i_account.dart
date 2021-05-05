abstract class IAccount {
  late String? id;

  late String email;

  late String password;

  late String phoneNumber;

  late String salt;

  late String address;

  late String status;

  late double balance;

  late int joinedDate;

  IAccount();

  Map<String, dynamic> toJson();
}
