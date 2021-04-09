import 'transaction.dart';
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
  // Map<String, dynamic> toJson() {
  //   // keys must be ordered for consistent hashing
  //   var block = <String, dynamic>{};

  //   block['index'] = index;
  //   block['timestamp'] = timestamp;
  //   block['proof'] = proof;
  //   block['prevHash'] = prevHash;
  //   //Sort in acending order of time.
  //   block['transactions'] = transactions!.map((t) => t.toJson()).toList();

  //   return block;
  // }

  // Block.fromJson(Map<String, dynamic> json)
  //     : index = json['index'],
  //       timestamp = json['timestamp'],
  //       proof = json['proof'],
  //       prevHash = json['prevHash'],
  //       transactions = json['transactions'];

  //  Block.fromJson(Map<String, dynamic> json) => _$BlockFromJson(json);
  // Map<String, dynamic> toJson() => _$BlockToJson(this);

  // Block _$BlockFromJson(Map<String, dynamic> json) {
  //   return Block(
  //     index: json['index'] as int,
  //     timestamp: json['timestamp'] as int,
  //     proof: json['proof'] as int,
  //     prevHash: json['prevHash'] as String,
  //   );
  // }

  // Map<String, dynamic> _$BlockToJson(Block instance) => <String, dynamic>{
  //       'index': instance.index,
  //       'timestamp': instance.timestamp,
  //       'proof': instance.proof,
  //       'prevHash': instance.prevHash,
  //     };
}
