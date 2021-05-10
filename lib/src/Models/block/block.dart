import 'package:sketchy_coins/packages.dart';
import 'package:sketchy_coins/src/models/interfaces/i_block.dart';

part 'block.g.dart';

@JsonSerializable(explicitToJson: true)
class Block implements IBlock {
  @override
  late int? index;

  @override
  int timestamp;

  @override
  @JsonKey(name: 'block_transactions')
  List? blockTransactions;

  @override
  int proof;

  @override
  @JsonKey(name: 'prev_hash')
  late String? prevHash;

  Block({
    this.index,
    required this.timestamp,
    required this.proof,
    required this.prevHash,
    required this.blockTransactions,
  });

  factory Block.fromJson(Map<String, dynamic> json) => _$BlockFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$BlockToJson(this);
}
