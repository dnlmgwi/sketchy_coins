import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sketchy_coins/src/Models/transaction/transaction.dart';
part 'mineResult.g.dart';

@HiveType(typeId: 2)
@JsonSerializable(explicitToJson: true)
class MineResult extends HiveObject {
  @HiveField(1)
  final String message;

  @HiveField(2)
  final int blockIndex;

  @HiveField(3)
  final bool? validBlock;

  @HiveField(4)
  final List<Transaction> transactions;
  
  @HiveField(5)
  final int proof;

  @HiveField(6)
  final String prevHash;

  MineResult({
    required this.message,
    required this.validBlock,
    required this.blockIndex,
    required this.transactions,
    required this.proof,
    required this.prevHash,
  });

  factory MineResult.fromJson(Map<String, dynamic> json) =>
      _$MineResultFromJson(json);
  Map<String, dynamic> toJson() => _$MineResultToJson(this);
}
