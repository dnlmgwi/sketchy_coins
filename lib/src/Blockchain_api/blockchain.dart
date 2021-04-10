import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:sketchy_coins/blockchain.dart';
import 'package:sketchy_coins/src/Models/transaction/transaction.dart';
import 'package:sketchy_coins/src/Services/localStore.dart';
import 'package:uuid/uuid.dart';
import 'kkoin.dart';
import 'package:sketchy_coins/src/Blockchain_api/kkoin.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:hex/hex.dart';

class Blockchain {
  final List<Block> _chain;

  final List<Transaction> _pendingTransactions;

  // //Adds a node to our peer table
  // Set addPeer(host) {
  //   return peers.union(host);
  // }

  // //Adds a node to our peer table
  // Set getPeers() {
  //   return peers;
  // }

  Blockchain()
      : _chain = [],
        _pendingTransactions = [] {
    // create genesis block
    newBlock(100, '1');
  }

  var blockchain = Hive.box<Block>('blockchain');
  var transactions = Hive.box<Transaction>('transactions');

  Block newBlock(int proof, String previousHash) {
    var pendingTransactions = _pendingTransactions;

    if (previousHash.isEmpty) {
      hash(_chain.last);
    }

    var block = Block(
      index: _chain.length,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      proof: proof,
      prevHash: previousHash,
      transactions: List.from(
        pendingTransactions,
      ),
    );

    blockchain.add(block);

    _chain.add(block);

    processPayments();

    _pendingTransactions.clear(); //Successfully Mined

    return block;
  }

  void processPayments() {
    if (DateTime.fromMillisecondsSinceEpoch(lastBlock.timestamp)
        .isBefore(DateTime.now())) {
      _pendingTransactions.forEach((element) {
        print('Processing ${element.toJson()}');
      });
    }
  }

  int newTransaction({
    required String sender,
    required String recipient,
    required double amount,
  }) {
    _pendingTransactions.add(
      Transaction(
        sender: sender,
        recipient: recipient,
        amount: amount,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        transID: Uuid().v4(),
        prevHash: lastBlock.prevHash,
        proof: lastBlock.proof,
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

  int proofOfWork(int? lastProof) {
    var proof = 0;
    while (!validProof(lastProof, proof)) {
      proof++;
    }
    return proof;
  }

  bool validProof(int? lastProof, int proof) {
    var guess = utf8.encode('$lastProof$proof');
    var guessHash = crypto.sha256.convert(guess).bytes;
    return HEX.encode(guessHash).substring(0, 4) == kKoin.difficulty;
  }

  String getBlockchain() {
    var jsonChain = json.encode(_chain);
    return jsonChain;
  }

  List<Block> getFullChain() {
    return _chain;
  }
}
