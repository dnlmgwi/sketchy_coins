
import 'package:sketchy_coins/src/transaction.dart';

class MineResult {
  final String message;
  final int blockIndex;
  final List<Transaction> transactions;
  final int proof;
  final String prevHash;

  MineResult(
    this.message,
    this.blockIndex,
    this.transactions,
    this.proof,
    this.prevHash,
  );
}
