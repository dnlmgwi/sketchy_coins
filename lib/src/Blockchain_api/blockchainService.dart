import 'package:crypto/crypto.dart' as crypto;
import 'package:sketchy_coins/packages.dart';

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

  // int newTransaction(
  //     {required String sender,
  //     required String recipient,
  //     required double amount}) {
  //   //Check if the sender & recipient are in the database
  //   if (accountValidation(sender, recipient)) {
  //     _accountService.checkAccountBalance(
  //         value: amount,
  //         account: _accountService.findAccount(
  //           accounts: _accountService.accountList,
  //           address: sender,
  //         ));

  //     if (accountStatusCheck(sender)) {
  //       addToPendingWithdraw(sender, recipient, amount);
  //       changeAccountStatusToProcessing(sender);
  //     } else {
  //       throw PendingTransactionException();
  //     }
  //   }
  //   return lastBlock.index + 1;
  // }

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

        Account? foundAccount;

        /// Edit User Account Balance
        /// String address - User P23 Address
        /// String value - Transaction Value
        /// String transactionType - 0: Withdraw, 1: Deposit, 2: Transfer 3: Reversal
        if (element.transType == 1) {
          foundAccount = depositProcess(foundAccount, element);
        } else {
          foundAccount = withdrawProcess(foundAccount, element);
        }
      });
    }
  }

  Account depositProcess(Account? foundAccount, Transaction element) {
    try {
      foundAccount = _accountService.findAccount(
        accounts: _accountService.accountList,
        address: element.recipient,
      );

      _accountService.editAccountBalance(
          account: foundAccount,
          value: element.amount,
          transactionType: element.transType);
      changeAccountStatusNormal(foundAccount.email);
    } catch (e) {
      print(e.toString());
      print('Failed Processing');
      rethrow;
    }
    return foundAccount;
  }

  Account withdrawProcess(Account? foundAccount, Transaction element) {
    try {
      foundAccount = _accountService.findAccount(
          accounts: _accountService.accountList, address: element.sender);

      _accountService.editAccountBalance(
          account: foundAccount,
          value: element.amount,
          transactionType: element.transType);
      changeAccountStatusNormal(foundAccount.email);
    } catch (e) {
      print(e.toString());
      print('Failed Processing');
      rethrow;
    }
    return foundAccount;
  }

  // int newDeposit({required String sender, required double amount}) {
  //   //Check if the sender & recipient are in the database
  //   if (accountPaymentValidation(sender) && accountStatusCheck(sender)) {
  //     _accountService.checkAccountBalance(
  //         value: amount,
  //         account: _accountService.findAccount(
  //           accounts: _accountService.accountList,
  //           address: sender,
  //         ));

  //     addToPendingDeposit(sender, sender, amount);
  //     changeAccountStatusToProcessing(sender);
  //   } else {
  //     throw PendingTransactionException();
  //   }
  //   return lastBlock.index + 1;
  // }
  //
  //   // void addToPendingMineDeposit(String recipient, double amount) {
  //   /// Edit User Account Balance
  //   /// String address - User P23 Address
  //   /// String value - Transaction Value
  //   /// String transactionType - 0: Withdraw, 1: Deposit
  //   pendingTansactions.add(Transaction(
  //     sender: recipient,
  //     recipient: recipient,
  //     amount: amount,
  //     timestamp: DateTime.now().millisecondsSinceEpoch,
  //     transID: Uuid().v4(),
  //     transType: 1,
  //   ));
  // }

  int initiateTransfer(
      {required String sender,
      required String recipient,
      required double amount}) {
    if (accountValidation(sender, recipient)) {
      //Check if the sender & recipient are in the database
      _accountService.checkAccountBalance(
          value: amount,
          account: _accountService.findAccount(
            accounts: _accountService.accountList,
            address: sender,
          ));

      if (accountStatusCheck(sender)) {
        addToPendingTransfer(sender, recipient, amount);
        changeAccountStatusToProcessing(sender);
      } else {
        throw PendingTransactionException();
      }
    }
    return lastBlock.index + 1;
  }

  void addToPendingDeposit(String sender, String recipient, double amount) {
    /// Edit User Account Balance
    /// String address - User P23 Address
    /// String value - Transaction Value
    /// String transactionType - 0: Withdraw, 1: Deposit
    pendingTansactions.add(Transaction(
      sender: sender,
      recipient: recipient,
      amount: amount,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      transID: Uuid().v4(),
      transType: 1,
    ));
  }

  void addToPendingTransfer(String sender, String recipient, double amount) {
    //Allows users to transfer points between each other
    /// String transactionType - 0: Withdraw, 1: Deposit, 2: Transfer
    var transId = Uuid().v4();
    var timestamp = DateTime.now().millisecondsSinceEpoch;

    pendingTansactions.add(Transaction(
      sender: sender,
      recipient: recipient,
      amount: amount,
      timestamp: timestamp,
      transID: transId,
      transType: 0,
    ));

    pendingTansactions.add(Transaction(
      sender: sender,
      recipient: recipient,
      amount: amount,
      timestamp: timestamp,
      transID: transId,
      transType: 1,
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

  bool accountPaymentValidation(String sender) {
    return _accountService.accountList.values.contains(
          _accountService.findAccount(
            accounts: _accountService.accountList,
            address: sender,
          ),
        ) ==
        true;
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
    required String recipient,
    required double amount,
  }) {
    //Check if the recipient is in the database
    if (recipientValidation(recipient)) {
      changeAccountStatusToProcessing(recipient);
      addToPendingDeposit(Env.systemAddress, recipient, amount);
    }
    return lastBlock.index + 1;
  }

  bool recipientValidation(String recipient) {
    return _accountService.accountList.values
        .contains(_accountService.findAccount(
      accounts: _accountService.accountList,
      address: recipient,
    ));
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
    return HEX.encode(guessHash).substring(0, 4) ==
        Env.difficulty;
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
