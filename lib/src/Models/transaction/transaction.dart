import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
part 'transaction.g.dart';

@HiveType(typeId: 3)
@JsonSerializable()
class Transaction extends HiveObject {
  @HiveField(15)
  String sender;

  @HiveField(16)
  String recipient;

  @HiveField(17)
  double amount;

  @HiveField(18)
  int timestamp;

  @HiveField(19)
  String transID;

  Transaction({
    required this.sender,
    required this.recipient,
    required this.amount,
    required this.timestamp,
    required this.transID,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionToJson(this);
}
