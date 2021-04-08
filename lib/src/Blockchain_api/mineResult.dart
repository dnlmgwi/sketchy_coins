import 'package:sketchy_coins/src/Blockchain_api/transaction.dart';

class MineResult {
  final String message;
  final int blockIndex;
  final bool validBlock;
  final List<Transaction> transactions;
  final int proof;
  final String prevHash;

  MineResult({
    this.message,
    this.validBlock,
    this.blockIndex,
    this.transactions,
    this.proof,
    this.prevHash,
  });

  Map<String, dynamic> toJson() {
    // keys must be ordered for consistent hashing
    var block = <String, dynamic>{};
    block['message'] = message;
    block['validBlock'] = validBlock;
    block['blockIndex'] = blockIndex;
    block['proof'] = proof;
    block['prevHash'] = prevHash;
    //Sort in acending order of time.
    block['transactions'] = transactions.map((t) => t.toJson()).toList();

    return block;
  }

  MineResult.fromJson(Map<String, dynamic> json)
      : message = json['address'],
        validBlock = json['validBlock'],
        blockIndex = json['blockIndex'],
        proof = json['proof'],
        prevHash = json['prevHash'],
        transactions = json['transactions'] ;
}
