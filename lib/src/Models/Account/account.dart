import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
part 'account.g.dart';

/// An annotation for the code generator to know that this class needs the
/// JSON serialization logic to be generated.
@JsonSerializable(explicitToJson: true)
@HiveType(typeId: 0)
class Account extends HiveObject {
  @HiveField(1)
  final String address;

  @HiveField(2)
  String status;

  @HiveField(3)
  double balance;

  Account({
    required this.address,
    required this.status,
    required this.balance,
  });

  factory Account.fromJson(Map<String, dynamic> json) =>
      _$AccountFromJson(json);

  Map<String, dynamic> toJson() => _$AccountToJson(this);
}
