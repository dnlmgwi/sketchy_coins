import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
part 'transactionPost.g.dart';

@HiveType(typeId: 3)
@JsonSerializable()
class TransactionPost extends HiveObject {
  @HiveField(15)
  String sender;

  @HiveField(16)
  String recipient;

  @HiveField(17)
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
