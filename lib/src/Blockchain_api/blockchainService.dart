import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:sketchy_coins/blockchain.dart';
import 'package:sketchy_coins/src/Account_api/accountExeptions.dart';
import 'package:sketchy_coins/src/Account_api/accountService.dart';
import 'package:sketchy_coins/src/Blockchain_api/blockchainValidation.dart';
import 'package:sketchy_coins/src/Models/Account/account.dart';
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
    if (blockchainStore.isEmpty) {
      newBlock(100, '1');
    }
  }

  final _accountService = AccountService();

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
        Account? foundAccount;

        if (element.sender ==
            '8e3153aa41771bf79089df1d858a274c9af598656688b188e803249ecb44de7f') {
          transactionType = 1;
          try {
            foundAccount = _accountService.findAccount(
                accounts: _accountService.accountList,
                address: element.recipient);

            _accountService.editAccountBalance(
                account: foundAccount,
                value: element.amount,
                transactionType: transactionType);
          } catch (e) {
            print(e.toString());
            print('Failed Processing');
          }
        } else {
          transactionType = 0;
          try {
            foundAccount = _accountService.findAccount(
                accounts: _accountService.accountList, address: element.sender);

            _accountService.editAccountBalance(
                account: foundAccount,
                value: element.amount,
                transactionType: transactionType);
          } catch (e) {
            print(e.toString());
            print('Failed Processing');
          }
        }

        changeAccountStatusNormal(foundAccount!.address);
      });
    }
  }

  int newTransaction({
    required String sender,
    required String recipient,
    required double amount,
  }) {
    //Check if the sender & recipient are in the database
    if (accountValidation(sender, recipient)) {
      _accountService.checkAccountBalance(
          value: amount,
          account: _accountService.findAccount(
            accounts: _accountService.accountList,
            address: sender,
          ));

      if (accountStatusCheck(sender)) {
        addToPendingTransactions(sender, recipient, amount);
        changeAccountStatusToProcessing(sender);
      } else {
        throw PendingTransactionException();
      }
    }
    return lastBlock.index + 1;
  }

  void addToPendingTransactions(
    String sender,
    String recipient,
    double amount,
  ) {
    pendingTansactions.add(Transaction(
      sender: sender,
      recipient: recipient,
      amount: amount,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      transID: Uuid().v4(),
    ));
  }

  bool accountStatusCheck(String sender) {
    return _accountService
            .findAccount(
              accounts: _accountService.accountList,
              address: sender,
            )
            .status ==
        'normal';
  }

  bool accountValidation(String sender, String recipient) {
    return _accountService.accountList.values.contains(
              _accountService.findAccount(
                accounts: _accountService.accountList,
                address: sender,
              ),
            ) ==
            true &&
        _accountService.accountList.values.contains(_accountService.findAccount(
              accounts: _accountService.accountList,
              address: recipient,
            )) ==
            true;
  }

  int newMineTransaction({
    required String sender,
    required String recipient,
    required double amount,
  }) {
    //Check if the recipient are in the database
    if (recipientValidation(recipient)) {
      changeAccountStatusToProcessing(recipient);
      addToPendingTransactions(sender, recipient, amount);
    }
    return lastBlock.index + 1;
  }

  bool recipientValidation(String recipient) {
    return recipientCheck(recipient);
  }

  bool recipientCheck(String recipient) {
    return _accountService.accountList.values
            .contains(_accountService.findAccount(
          accounts: _accountService.accountList,
          address: recipient,
        )) ==
        true;
  }

  void changeAccountStatusToProcessing(String sender) {
    _accountService
        .findAccount(accounts: _accountService.accountList, address: sender)
        .status = 'processing';
    _accountService
        .findAccount(accounts: _accountService.accountList, address: sender)
        .save();
  }

  void changeAccountStatusNormal(String sender) {
    _accountService
        .findAccount(accounts: _accountService.accountList, address: sender)
        .status = 'normal';
    _accountService
        .findAccount(accounts: _accountService.accountList, address: sender)
        .save();
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
    var jsonChain = [];
    blockchainStore.values.forEach((element) {
      jsonChain.add(element.toJson());
    });
    json.encode(jsonChain);
    return jsonChain.toString();
  }
}
