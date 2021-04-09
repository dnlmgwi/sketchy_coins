import 'package:json_annotation/json_annotation.dart';
part 'transaction.g.dart';

@JsonSerializable()
class Transaction {
  String? sender;
  String? recipient;
  double? amount;
  int? timestamp;
  int? proof;
  String? prevHash;

  Transaction(
    this.sender,
    this.recipient,
    this.amount,
    this.timestamp,
  );

   factory Transaction.fromJson(Map<String, dynamic> json) => _$TransactionFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionToJson(this);
}
