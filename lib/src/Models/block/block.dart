import 'package:sketchy_coins/packages.dart';

part 'block.g.dart';

@JsonSerializable(explicitToJson: true)
class Block {
  String id;

  int? index;

  int timestamp;

  @JsonKey(name: 'block_transactions')
  List blockTransactions;

  int proof;

  @JsonKey(name: 'prev_hash')
  String prevHash;

  Block({
    this.index,
    required this.timestamp,
    required this.proof,
    required this.prevHash,
    required this.id,
    required this.blockTransactions,
  });

  factory Block.fromJson(Map<String, dynamic> json) => _$BlockFromJson(json);

  Map<String, dynamic> toJson() => _$BlockToJson(this);
}
