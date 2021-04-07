import 'package:sketchy_coins/src/transaction.dart';

class Block {
  final int index;
  final int timestamp;
  final List<Transaction> transactions;
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
}
