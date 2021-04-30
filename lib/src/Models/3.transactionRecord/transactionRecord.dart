import 'package:sketchy_coins/packages.dart';
part 'transactionRecord.g.dart';

@HiveType(typeId: 3)
@JsonSerializable()
class TransactionRecord extends HiveObject {
  @HiveField(1)
  String sender;

  @HiveField(2)
  String recipient;

  @HiveField(3)
  double amount;

  @HiveField(4)
  int timestamp;

  @HiveField(5)
  String transID;

  @HiveField(6)
  int transType;

  // @HiveField(7)
  // Location location;

  TransactionRecord({
    required this.sender,
    required this.recipient,
    required this.amount,
    required this.timestamp,
    required this.transID,
    required this.transType,
    // required this.location,
  });

  factory TransactionRecord.fromJson(Map<String, dynamic> json) =>
      _$TransactionRecordFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionRecordToJson(this);
}
