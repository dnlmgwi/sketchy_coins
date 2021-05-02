import 'package:sketchy_coins/packages.dart';

part 'account.g.dart';

/// An annotation for the code generator to know that this class needs the
/// JSON serialization logic to be generated.
@JsonSerializable(explicitToJson: true)
class Account {
  String? id;

  String email;

  String password;

  String phoneNumber;

  String salt;

  String address;

  String status;

  double balance;

  int joinedDate;

  Account({
    this.id,
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.salt,
    required this.status,
    required this.address,
    required this.balance,
    required this.joinedDate,
  });

  factory Account.fromJson(Map<String, dynamic> json) =>
      _$AccountFromJson(json);

  Map<String, dynamic> toJson() => _$AccountToJson(this);
}
