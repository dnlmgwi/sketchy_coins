import 'package:sketchy_coins/packages.dart';

part 'registerRequest.g.dart';

/// An annotation for the code generator to know that this class needs the
/// JSON serialization logic to be generated.
@JsonSerializable(explicitToJson: true)
class RegisterRequest {
  late final int? age;
  late final String? gender;
  late final String? password;
  late final String? phoneNumber;

  String? get getGender => gender;

  set setGender(gender) => this.gender = gender;

  int? get getAge => age;

  set setAge(age) => this.age = age;

  String? get getPassword => password;

  set setPassword(password) => this.password = password;

  String? get getPhoneNumber => phoneNumber;

  set setPhoneNumber(phoneNumber) => this.phoneNumber = phoneNumber;

  RegisterRequest({
    required this.age,
    required this.gender,
    required this.password,
    required this.phoneNumber,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}
