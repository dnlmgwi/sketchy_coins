import 'package:sketchy_coins/packages.dart';

part 'transAccount.g.dart';

@JsonSerializable(explicitToJson: true)
class TransAccount {
  String address;

  String phoneNumber;

  String status;

  double balance;

  String get getAddress => address;

  set setAddress(String address) => this.address = address;

  String get getPhoneNumber => phoneNumber;

  set setPhoneNumber(String phoneNumber) => this.phoneNumber = phoneNumber;

  String get getStatus => status;

  set setStatus(status) => this.status = status;

  double get getBalance => balance;

  set setBalance(balance) => this.balance = balance;

  TransAccount({
    required this.status,
    required this.phoneNumber,
    required this.address,
    required this.balance,
  });

  factory TransAccount.fromJson(Map<String, dynamic> json) =>
      _$TransAccountFromJson(json);

  Map<String, dynamic> toJson() => _$TransAccountToJson(this);
}
