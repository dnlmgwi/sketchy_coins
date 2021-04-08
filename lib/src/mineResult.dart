import 'package:sketchy_coins/src/transaction.dart';

class MineResult {
  final String message;
  final int blockIndex;
  final List<Transaction> transactions;
  final int proof;
  final String prevHash;

  MineResult({
    this.message,
    this.blockIndex,
    this.transactions,
    this.proof,
    this.prevHash,

    block['message'] = message;
    block['blockIndex'] = blockIndex;
    block['proof'] = proof;
    block['prevHash'] = prevHash;
    //Sort in acending order of time.
    block['transactions'] = transactions.map((t) => t.toJson()).toList();

    return block;
  }
}
