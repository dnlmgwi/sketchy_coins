import 'package:sketchy_coins/packages.dart';
part 'mineResult.g.dart';

@JsonSerializable(explicitToJson: true)
class MineResult {
  final String message;

  final int? blockIndex;

  final bool? validBlock;

  final List? transactions;

  final int proof;

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
