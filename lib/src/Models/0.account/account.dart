import 'package:sketchy_coins/packages.dart';
part 'account.g.dart';

/// An annotation for the code generator to know that this class needs the
/// JSON serialization logic to be generated.
@JsonSerializable(explicitToJson: true)
@HiveType(typeId: 0)
class Account extends HiveObject {
  @HiveField(1)
  String email;

  @HiveField(2)
  String password;

  @HiveField(3)
  String phoneNumber;

  @HiveField(4)
  String salt;

  @HiveField(5)
  String address;

  @HiveField(6)
  String status;

  @HiveField(7)
  double balance;

  @HiveField(8)
  int joinedDate;

  Account({
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
