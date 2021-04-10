import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
part 'transaction.g.dart';

@HiveType(typeId: 4)
@JsonSerializable()
class Transaction extends HiveObject {
  @HiveField(18)
  String sender;

  @HiveField(19)
  String recipient;

  @HiveField(20)
  double amount;

  @HiveField(21)
  int timestamp;

  @HiveField(22)
  String transID;

  @HiveField(23)
  int proof;

  @HiveField(24)
  String prevHash;

  Transaction({
    required this.sender,
    required this.recipient,
    required this.amount,
    required this.timestamp,
    required this.transID,
    required this.proof,
    required this.prevHash,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionToJson(this);
}
