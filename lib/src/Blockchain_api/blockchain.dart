import 'dart:convert';
import '../transaction.dart';
import 'block.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:hex/hex.dart';

class Blockchain {
  final List<Block> _chain;
  final List<Transaction> _pendingTransactions;

  Blockchain()
      : _chain = [],
        _pendingTransactions = [] {
    // create genesis block
    newBlock(100, '1');
  }

  Block newBlock(int proof, String previousHash) {
    var pendingTransactions = _pendingTransactions;

    previousHash ??= hash(_chain.last);

    var block = Block(
      index: _chain.length,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      prevHash: previousHash,
      proof: proof,
      transactions: List.from(pendingTransactions),
    );

    _chain.add(block);

    _pendingTransactions.clear(); //Successfully Mined

    return block;
  }

  int newTransaction({String sender, String recipient, double amount}) {
    _pendingTransactions.add(
      Transaction(
        sender: sender,
        amount: amount,
        recipient: recipient,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    return lastBlock.index + 1;
  }

  Block get lastBlock {
    return _chain.last;
  }

  List<Transaction> get pendingTransactions {
    return _pendingTransactions;
  }

  String hash(Block block) {
    var blockStr = json.encode(block.toJson());
    var bytes = utf8.encode(blockStr);
    var converted = crypto.sha256.convert(bytes).bytes;
    return HEX.encode(converted);
  }

  int proofOfWork(int lastProof) {
    var proof = 0;
    while (!validProof(lastProof, proof)) {
      proof++;
    }
    return proof;
  }

  bool validProof(int lastProof, int proof) {
    var guess = utf8.encode('$lastProof$proof');
    var guessHash = crypto.sha256.convert(guess).bytes;
    return HEX.encode(guessHash).substring(0, 4) == '0000';
  }

  String getBlockchain() {
    var jsonChain = json.encode(_chain);
    return jsonChain;
  }

  List<Block> chain() {
    return _chain;
  }
}
