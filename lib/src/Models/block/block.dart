import 'package:json_annotation/json_annotation.dart';
import 'package:sketchy_coins/src/Models/transaction/transaction.dart';
part 'block.g.dart';

/// An annotation for the code generator to know that this class needs the
/// JSON serialization logic to be generated.
@JsonSerializable(explicitToJson: true)
class Block {
  int index;
  int timestamp;
  List<Transaction> transactions;
  int proof;
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
