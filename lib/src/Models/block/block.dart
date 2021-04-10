import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sketchy_coins/src/Models/transaction/transaction.dart';
part 'block.g.dart';

@HiveType(typeId: 1)
@JsonSerializable(explicitToJson: true)
class Block extends HiveObject {
  
  @HiveField(4)
  int index;

  @HiveField(5)
  int timestamp;

  @HiveField(6)
  List<Transaction> transactions;
  
  @HiveField(7)
  int proof;

  @HiveField(8)
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
