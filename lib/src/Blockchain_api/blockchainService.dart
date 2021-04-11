import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:sketchy_coins/blockchain.dart';
import 'package:sketchy_coins/src/Account_api/accountService.dart';
import 'package:sketchy_coins/src/Blockchain_api/blockchainValidation.dart';
import 'package:sketchy_coins/src/Models/transaction/transaction.dart';
import 'package:uuid/uuid.dart';
import 'kkoin.dart';
import 'package:sketchy_coins/src/Blockchain_api/kkoin.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:hex/hex.dart';

class BlockchainService {
  //Adds a node to our peer table
  // Set addPeer(host) {
  //   return peers.union(host);
  // }

  //Adds a node to our peer table
  // Set getPeers() {
  //   return peers;
  // }

  BlockchainService() {
    newBlock(100, '1');
  }

  AccountService _accountService = AccountService();

  var blockChainValidity = BlockChainValidity();
  var blockchainStore = Hive.box<Block>('blockchain');
  var pendingTansactions = Hive.box<Transaction>('transactions');

  Block newBlock(int proof, String previousHash) {
    if (previousHash.isEmpty) {
      hash(blockchainStore.values.last);
    }

    var block = Block(
      index: blockchainStore.values.length,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      proof: proof,
      prevHash: previousHash,
      transactions: List.from(
        pendingTransactions.toSet(),
      ),
    );
    blockchainStore.add(block);
    processPayments();
    pendingTansactions.clear(); //Successfully Mined

    return block;
  }

  void processPayments() {
    if (DateTime.fromMillisecondsSinceEpoch(
            blockchainStore.values.last.timestamp)
        .isBefore(DateTime.now())) {
      pendingTansactions.values.forEach((element) {
        print('Processing ${element.toJson()}');

        var transactionType;

        if (element.sender == '0') {
          transactionType = 0;
        } else {
          transactionType = 1;
        }

        try {
          var foundAccount = _accountService.findAccount(
              data: _accountService.accountList, address: element.sender);

          _accountService.editAccountBalance(
              account: foundAccount,
              value: element.amount,
              transactionType: transactionType);
        } catch (e) {
          print(e.toString());
        }
      });
    }
  }

  int newTransaction({
    required String sender,
    required String recipient,
    required double amount,
  }) {
    pendingTansactions.add(Transaction(
      sender: sender,
      recipient: recipient,
      amount: amount,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      transID: Uuid().v4(),
    ));
    return lastBlock.index + 1;
  }

  Block get lastBlock {
    return blockchainStore.values.last;
  }

  List<Transaction> get pendingTransactions {
    return pendingTansactions.values.toList();
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
    var jsonChain = json.encode(blockchainStore.values.last.toJson());
    return jsonChain;
  }
}
