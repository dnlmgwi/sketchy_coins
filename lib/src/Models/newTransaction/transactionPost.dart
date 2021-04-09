import 'package:json_annotation/json_annotation.dart';
part 'transactionPost.g.dart';

@JsonSerializable()
class TransactionPost {
  String sender;
  String recipient;
  double amount;

  TransactionPost({
    required this.sender,
    required this.recipient,
    required this.amount,
  });

  factory TransactionPost.fromJson(Map<String, dynamic> json) =>
      _$TransactionPostFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionPostToJson(this);
}
