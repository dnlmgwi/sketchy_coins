import 'dart:convert';
import 'dart:io';
import 'package:sketchy_coins/src/Blockchain_api/blockchainValidation.dart';
import 'package:sketchy_coins/src/kkoin.dart';

import 'transaction.dart';
import 'block.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:hex/hex.dart';

class Blockchain {
  static Iterable l = json.decode(File('chain.json').readAsStringSync());
  List<Block> chain = List<Block>.from(l.map((model) => Block.fromJson(model)));

  final List<Transaction> _pendingTransactions;
  BlockChainValidity blockChainValidity;

  Blockchain()
      : chain = [],
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

    previousHash ??= hash(chain.last);

    var block = Block(
      index: chain.length,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      prevHash: previousHash,
      proof: proof,
      transactions: List.from(pendingTransactions),
    );

    chain.add(block);

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
    return chain.last;
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
    return HEX.encode(guessHash).substring(0, 4) == kKoin.difficulty;
  }

  String getBlockchain() {
    var jsonChain = json.encode(chain);
    return jsonChain;
  }

  List<Block> getFullChain() {
    return chain;
  }
}
