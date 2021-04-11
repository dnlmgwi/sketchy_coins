import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sketchy_coins/src/Models/transaction/transaction.dart';
part 'block.g.dart';

@HiveType(typeId: 0)
@JsonSerializable(explicitToJson: true)
class Block extends HiveObject {
  
  @HiveField(1)
  int index;

  @HiveField(2)
  int timestamp;

  @HiveField(3)
  List<Transaction> transactions;
  
  @HiveField(4)
  int proof;

  @HiveField(5)
  final String prevHash;

  Block({
    required this.index,
    required this.timestamp,
    required this.proof,
    required this.prevHash,
    required this.transactions,
  });

  factory Block.fromJson(Map<String, dynamic> json) => _$BlockFromJson(json);

  Map<String, dynamic> toJson() => _$BlockToJson(this);
}
