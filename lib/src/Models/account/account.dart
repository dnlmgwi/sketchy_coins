import 'package:sketchy_coins/packages.dart';

part 'account.g.dart';

/// An annotation for the code generator to know that this class needs the
/// JSON serialization logic to be generated.
@JsonSerializable(explicitToJson: true)
class Account extends IAccount {
  @override
  String? id;

  @override
  String gender;

  @override
  String password;

  @override
  @JsonKey(name: 'phone_number')
  String phoneNumber;

  @override
  String salt;

  @override
  String status;

  @override
  int balance;

  @override
  @JsonKey(name: 'joined_date')
  int joinedDate;

  @override
  int age;

  @override
  @JsonKey(name: 'last_trans')
  late int? lastTrans;

  String? get getId => id;

  set setId(id) => this.id = id;

  String get getPassword => password;

  set setPassword(password) => this.password = password;

  String get getPhoneNumber => phoneNumber;

  set setPhoneNumber(phoneNumber) => this.phoneNumber = phoneNumber;

  String get getSalt => salt;

  set setSalt(salt) => this.salt = salt;

  String get getGender => gender;

  set setGender(String gender) => this.gender = gender;

  String get getStatus => status;

  set setStatus(status) => this.status = status;

  int get getBalance => balance;

  set setBalance(balance) => this.balance = balance;

  int get getJoinedDate => joinedDate;

  set setJoinedDate(joinedDate) => this.joinedDate = joinedDate;

  int? get getLastTrans => lastTrans;

  set setLastTrans(lastTrans) => this.lastTrans = lastTrans;

  int? get getAge => age;

  set setAge(int age) => this.age = age;

  Account({
    this.id,
    required this.gender,
    required this.password,
    required this.phoneNumber,
    required this.salt,
    required this.status,
    required this.balance,
    required this.joinedDate,
    required this.age,
    this.lastTrans,
  });

  factory Account.fromJson(Map<String, dynamic> json) =>
      _$AccountFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AccountToJson(this);
}
