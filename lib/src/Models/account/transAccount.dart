import 'package:sketchy_coins/packages.dart';

part 'transAccount.g.dart';

@JsonSerializable(explicitToJson: true)
class TransAccount {
  late String? id;

  @JsonKey(name: 'phone_number')
  String phoneNumber;

  String status;

  int balance;

  @JsonKey(name: 'last_trans')
  int? lastTrans;

  String get getid => id!;

  set setid(String id) => this.id = id;

  String get getPhoneNumber => phoneNumber;

  set setPhoneNumber(String phoneNumber) => this.phoneNumber = phoneNumber;

  String get getStatus => status;

  set setStatus(status) => this.status = status;

  int get getBalance => balance;

  set setBalance(balance) => this.balance = balance;

  int? get getLastTrans => lastTrans;

  set setLastTrans(lastTrans) => this.lastTrans = lastTrans;

  TransAccount({
    required this.status,
    required this.phoneNumber,
    required this.id,
    required this.balance,
    required this.lastTrans,
  });

  factory TransAccount.fromJson(Map<String, dynamic> json) =>
      _$TransAccountFromJson(json);

  Map<String, dynamic> toJson() => _$TransAccountToJson(this);
}
