import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sketchy_coins/src/Models/transaction/transaction.dart';
part 'account.g.dart';

/// An annotation for the code generator to know that this class needs the
/// JSON serialization logic to be generated.
@JsonSerializable(explicitToJson: true)
@HiveType(typeId: 4)
class Account extends HiveObject {
  @HiveField(20)
  final String address;

  @HiveField(21)
  final String status;

  @HiveField(22)
  final double balance;

  @HiveField(23)
  final List<Transaction>? transactions;

  Account({
    required this.address,
    required this.status,
    required this.balance,
    required this.transactions,
  });

  factory Account.fromJson(Map<String, dynamic> json) =>
      _$AccountFromJson(json);

  Map<String, dynamic> toJson() => _$AccountToJson(this);
}
