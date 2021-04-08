import 'package:sketchy_coins/src/Blockchain_api/transaction.dart';
import 'package:json_annotation/json_annotation.dart';

class Block {
  int index;
  int timestamp;
  List<Transaction> transactions;
  int proof;
  final String prevHash;

  Block({
    this.index,
    this.timestamp,
    this.transactions,
    this.proof,
    this.prevHash,
  });

  Map<String, dynamic> toJson() {
    // keys must be ordered for consistent hashing
    var block = <String, dynamic>{};

    block['index'] = index;
    block['timestamp'] = timestamp;
    block['proof'] = proof;
    block['prevHash'] = prevHash;
    //Sort in acending order of time.
    block['transactions'] = transactions.map((t) => t.toJson()).toList();

    return block;
  }

  Block.fromJson(Map<String, dynamic> json)
      : index = json['index'],
        timestamp = json['timestamp'],
        proof = json['proof'],
        prevHash = json['prevHash'],
        transactions = json['transactions'];

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
