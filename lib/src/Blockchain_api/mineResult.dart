import 'package:json_annotation/json_annotation.dart';
import 'transaction.dart';
part 'mineResult.g.dart';

@JsonSerializable(explicitToJson: true)
class MineResult {
  final String? message;
  final int? blockIndex;
  final bool? validBlock;
  final List<Transaction>? transactions;
  final int? proof;
  final String? prevHash;

  MineResult({
    this.message,
    this.validBlock,
    this.blockIndex,
    this.transactions,
    this.proof,
    this.prevHash,
  });

  factory MineResult.fromJson(Map<String, dynamic> json) =>
      _$MineResultFromJson(json);
  Map<String, dynamic> toJson() => _$MineResultToJson(this);
}
