import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:sketchy_coins/blockchain.dart';
import 'package:sketchy_coins/src/Models/transaction/transaction.dart';
import 'package:uuid/uuid.dart';
import 'kkoin.dart';
import 'package:sketchy_coins/src/Blockchain_api/kkoin.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:hex/hex.dart';

class Blockchain {
  // //Adds a node to our peer table
  // Set addPeer(host) {
  //   return peers.union(host);
  // }

  // //Adds a node to our peer table
  // Set getPeers() {
  //   return peers;
  // }

  Blockchain() {
    newBlock(100, '1');
  }

  var blockchain = Hive.box<Block>('blockchain');
  var transactions = Hive.box<Transaction>('transactions');

  Block newBlock(int proof, String previousHash) {
    if (previousHash.isEmpty) {
      hash(blockchain.values.last);
    }

    var block = Block(
      index: blockchain.values.length,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      proof: proof,
      prevHash: previousHash,
      transactions: List.from(
        pendingTransactions.toSet(),
      ),
    );

    blockchain.add(block);

    processPayments();

    transactions.clear(); //Successfully Mined

    return block;
  }

  void processPayments() {
    if (DateTime.fromMillisecondsSinceEpoch(lastBlock.timestamp)
        .isBefore(DateTime.now())) {
      transactions.values.forEach((element) {
        print('Processing ${element.toJson()}');
      });
    }
  }

  int newTransaction({
    required String sender,
    required String recipient,
    required double amount,
  }) {
    transactions.add(
      Transaction(
        sender: sender,
        recipient: recipient,
        amount: amount,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        transID: Uuid().v4(),
      ),
    );
    return lastBlock.index + 1;
  }

  Block get lastBlock {
    return blockchain.values.last;
  }

  List<Transaction> get pendingTransactions {
    return transactions.values.toList();
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
    var jsonChain = json.encode(blockchain.values.last.toJson());
    return jsonChain;
  }

  // List<Block> getFullChain() {
  //   return _chain;
  // }
}
