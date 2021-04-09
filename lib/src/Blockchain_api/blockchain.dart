import 'dart:convert';
import 'dart:io';
import 'kkoin.dart';
import 'blockchainValidation.dart';
import 'transaction.dart';
import 'block.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:hex/hex.dart';

class Blockchain {
 
  List<Block> _chain;
  final List<Transaction> _pendingTransactions;
  BlockChainValidity? blockChainValidity;

  Blockchain()
      : _chain = [],
       _pendingTransactions = [] {
    // create genesis block
    newBlock(100, '1');
  }

  // //Adds a node to our peer table
  // Set addPeer(host) {
  //   return peers.union(host);
  // }

  // //Adds a node to our peer table
  // Set getPeers() {
  //   return peers;
  // }

  Block newBlock(int proof, String previousHash) {
    var pendingTransactions = _pendingTransactions;

    previousHash ??= hash(_chain.last);

    var block = Block(
      _chain.length,
      DateTime.now().millisecondsSinceEpoch,
      proof,
      previousHash,
      List.from(pendingTransactions),
    );

    _chain.add(block);

    _pendingTransactions.clear(); //Successfully Mined

    return block;
  }

  int newTransaction({String? sender, String? recipient, double? amount}) {
    _pendingTransactions.add(
      Transaction(
        sender,
        recipient,
        amount,
        DateTime.now().millisecondsSinceEpoch,
      ),
    );
    return lastBlock.index! + 1;
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
