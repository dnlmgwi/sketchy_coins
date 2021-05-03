import 'package:sketchy_coins/packages.dart';

part 'block.g.dart';

@JsonSerializable(explicitToJson: true)
class Block {
  int? index;

  int timestamp;

  List? transactions;

  int proof;

  final String prevHash;

  Block({
    this.index,
    required this.timestamp,
    required this.proof,
    required this.prevHash,
    required this.transactions,
  });

  factory Block.fromJson(Map<String, dynamic> json) => _$BlockFromJson(json);

  Map<String, dynamic> toJson() => _$BlockToJson(this);
}
