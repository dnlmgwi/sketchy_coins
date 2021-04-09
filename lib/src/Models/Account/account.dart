import 'package:json_annotation/json_annotation.dart';
import 'package:sketchy_coins/src/Models/transaction/transaction.dart';
part 'account.g.dart';

/// An annotation for the code generator to know that this class needs the
/// JSON serialization logic to be generated.
@JsonSerializable(explicitToJson: true)
class Account {
  final String address;
  final String status;
  final double balance;
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
