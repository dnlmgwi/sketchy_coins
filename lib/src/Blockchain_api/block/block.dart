import 'package:sketchy_coins/src/Blockchain_api/transaction/transaction.dart';
import 'package:json_annotation/json_annotation.dart';

part 'block.g.dart';

/// An annotation for the code generator to know that this class needs the
/// JSON serialization logic to be generated.
@JsonSerializable(explicitToJson: true)
class Block {
  int? index;
  int? timestamp;
  List<Transaction>? transactions;
  int? proof;
  final String? prevHash;

  Block(
    this.index,
    this.timestamp,
    this.proof,
    this.prevHash,
    this.transactions,
  );

  factory Block.fromJson(Map<String, dynamic> json) => _$BlockFromJson(json);

  Map<String, dynamic> toJson() => _$BlockToJson(this);
}
