import 'package:sketchy_coins/packages.dart';

part 'account.g.dart';

/// An annotation for the code generator to know that this class needs the
/// JSON serialization logic to be generated.
@JsonSerializable(explicitToJson: true)
class Account extends IAccount {
  @override
  late String? id;

  @override
  String email;

  @override
  String password;

  @override
  String phoneNumber;

  @override
  String salt;

  @override
  String status;

  @override
  double balance;

  @override
  int joinedDate;

  String? get getId => id;

  set setId(id) => this.id = id;

  String get getEmail => email;

  set setEmail(email) => this.email = email;

  String get getPassword => password;

  set setPassword(password) => this.password = password;

  String get getPhoneNumber => phoneNumber;

  set setPhoneNumber(phoneNumber) => this.phoneNumber = phoneNumber;

  String get getSalt => salt;

  set setSalt(salt) => this.salt = salt;

  // String get getid => id;

  // set setAddress(address) => this.address = address;

  String get getStatus => status;

  set setStatus(status) => this.status = status;

  double get getBalance => balance;

  set setBalance(balance) => this.balance = balance;

  int get getJoinedDate => joinedDate;

  set setJoinedDate(joinedDate) => this.joinedDate = joinedDate;

  Account({
    this.id,
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.salt,
    required this.status,
    // required this.address,
    required this.balance,
    required this.joinedDate,
  });

  factory Account.fromJson(Map<String, dynamic> json) =>
      _$AccountFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AccountToJson(this);
}
