import 'package:crypto/crypto.dart' as crypto;
import 'package:sketchy_coins/packages.dart';

class BlockchainService {
  DatabaseService databaseService;

  BlockchainService({required this.databaseService});

  var accountService = AccountService(databaseService: DatabaseService());
  var blockChainValidity = BlockChainValidationService();

  var pendingTansactions = Hive.box<TransactionRecord>('transactions');
  var pendingDepositsTansactions =
      Hive.box<RechargeNotification>('rechargeNotifications');

  Future<Block> newBlock(int proof, String previousHash) async {
    var prevBlock;
    if (previousHash.isEmpty) {
      hash(Block.fromJson(prevBlock.data));
    }

    try {
      prevBlock = await DatabaseService.client
          .from('blockchain')
          .select()
          .limit(1)
          .order('timestamp', ascending: false)
          .execute();

      var currentTransactions = pendingTansactions.values.toList();

      await processPayments()
          .onError((error, stackTrace) =>
              throw Exception(' Error: $error StackTrace: $stackTrace'))
          .then(
            (_) => DatabaseService.client
                .from('blockchain')
                .insert(
                  [
                    Block(
                      index: Block.fromJson(prevBlock.data[0]).index! + 1,
                      timestamp: DateTime.now().millisecondsSinceEpoch,
                      proof: proof,
                      prevHash: previousHash,
                      transactions: List.from(
                        currentTransactions,
                      ),
                    ).toJson()
                  ],
                )
                .execute()
                .then((_) => currentTransactions.clear()),
          )
          .onError(
            (error, stackTrace) =>
                throw Exception(' Error: $error StackTrace: $stackTrace'),
          );
      //Successfully Mined

      if (prevBlock.error != null) {
        throw prevBlock.error!.message;
      }

      var latestBlock = await DatabaseService.client
          .from('blockchain')
          .select()
          .limit(1)
          .order('timestamp', ascending: false)
          .execute();
      // .whenComplete(
      //   //When This Future Completes Clear the Pending List.
      //   () => pendingTansactions.clear(),
      // );

      return Block.fromJson(latestBlock.data[0]);
    } on PostgrestError catch (e) {
      print(e.code);
      print(e.message);
      rethrow;
    }
  }

  Future<void> processPayments() async {
    try {
      var response = await DatabaseService.client
          .from('blockchain')
          .select()
          .limit(1)
          .order('timestamp', ascending: false)
          .execute();

      if (DateTime.fromMillisecondsSinceEpoch(
              Block.fromJson(response.data[0]).timestamp)
          .isBefore(DateTime.now())) {
        for (var transaction in pendingTansactions.values) {
          switch (transaction.transType) {
            case 0:
              await withdrawProcess(transaction);
              break;
            case 1:
              await depositProcess(transaction);
              break;

            case 2:
              await transferProcess(transaction);
              break;
          }
          await DatabaseService.client
              .from('transactions')
              .insert([transaction.toJson()])
              .execute()
              .then((_) => transaction.delete());
        }
      }
      if (response.error != null) {
        throw response.error!.message;
      }

      return response.data;
    } on PostgrestError catch (e) {
      print(e.code);
      print(e.message);
      rethrow;
    }
  }

  Future<void> depositProcess(TransactionRecord element) async {
    try {
      var foundAccount = await accountService.findAccount(
        id: element.recipient,
      );

      await editAccountBalance(
          senderAccount: foundAccount,
          value: element.amount,
          transactionType: element.transType);
      await changeAccountStatusNormal(foundAccount.id!);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> withdrawProcess(TransactionRecord element) async {
    try {
      var foundAccount = await accountService.findAccount(id: element.sender);

      await editAccountBalance(
          senderAccount: foundAccount,
          value: element.amount,
          transactionType: element.transType);
      await changeAccountStatusNormal(foundAccount.id);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> transferProcess(TransactionRecord element) async {
    try {
      var recipientAccount = await accountService.findAccount(
        id: element.recipient,
      );

      var senderAccount = await accountService.findAccount(
        id: element.sender,
      );

      /// Edit User Account Balance
      /// String id - User P23 id
      /// String value - Transaction Value
      /// String transactionType - 0: Withdraw, 1: Deposit
      ///
      await editAccountBalance(
        senderAccount: senderAccount,
        recipientAccount: recipientAccount,
        value: element.amount,
        transactionType: element.transType,
      );
      await changeAccountStatusNormal(senderAccount.id);
    } catch (e) {
      rethrow;
    }
  }

  Future editAccountBalance({
    required TransAccount senderAccount,
    TransAccount? recipientAccount,
    required double value,
    required int transactionType,
  }) async {
    try {
      switch (transactionType) {
        case 0:
          await withdraw(
            account: senderAccount,
            value: value,
          );

          break;
        case 1:
          await deposit(
            account: senderAccount,
            value: value,
          );
          break;
        case 2:
          await transfer(
            value: value,
            senderAccount: senderAccount,
            recipientAccount: recipientAccount!,
          );
          break;
      }
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }

  Future<TransAccount> deposit({
    required double value,
    required TransAccount account,
  }) async {
    PostgrestResponse response;
    try {
      response = await DatabaseService.client
          .from('accounts')
          .update({'balance': account.balance + value})
          .eq('id', account.id)
          .execute();
      return TransAccount.fromJson(response.data[0]);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> transfer({
    required double value,
    required TransAccount senderAccount,
    required TransAccount recipientAccount,
  }) async {
    try {
      await DatabaseService.client
          .from('accounts')
          .update({'balance': senderAccount.balance - value})
          .eq('id', senderAccount.id)
          .execute()
          .whenComplete(() => DatabaseService.client
              .from('accounts')
              .update({'balance': recipientAccount.balance + value})
              .eq('id', recipientAccount.id)
              .execute());
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> withdraw({
    required double value,
    required TransAccount account,
  }) async {
    //TODO: External Provider Needed
    try {
      if (value > account.balance) {
        throw InsufficientFundsException();
      } else if (value < double.parse(Env.minTransactionAmount)) {
        throw InvalidInputException();
      } else {
        await DatabaseService.client
            .from('accounts')
            .update({'balance': account.balance - value})
            .eq('id', account.id)
            .execute();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<double> checkAccountBalance({
    required double value,
    required TransAccount account,
  }) async {
    try {
      if (await accountStatusCheck(account.id!)) {
        if (value > account.balance) {
          throw InsufficientFundsException();
        } else if (value < double.parse(Env.minTransactionAmount)) {
          throw InvalidInputException();
        }
      } else {
        PendingTransactionException();
      }
    } catch (e) {
      rethrow;
    }

    return account.balance;
  }

  Future initiateRecharge({required Box<RechargeNotification> data}) async {
    try {
      //Check if TransID and Amount match the recieved notification.
      print('Total Items: ${data.values.length}');

      for (var item in data.values) {
        await accountService
            .findRecipientAccount(phoneNumber: item.phoneNumber)
            .then((account) => addToPendingDeposit(
                    item.transID, account.id!, extractAmount(item))
                .then((_) => changeClaimToTrue(item.transID))
                .then((_) => changeAccountStatusToProcessing(account.id!))
                .then((_) => item.delete()));
      }
    } catch (e) {
      rethrow;
    }
  }

  double extractAmount(RechargeNotification item) =>
      double.parse(item.amount.toString().split('MK').last);

  Future<void> initiateTransfer({
    required String? senderid,
    required String recipientid,
    required double amount,
  }) async {
    if (senderid == recipientid) {
      //Prevents User from Sending Points To Self Compounding Account Balance.
      throw SelfTransferException();
    }

    if (await recipientValidation(recipientid)) {
      //Check if the sender & recipient are in the system
      await checkAccountBalance(
          value: amount,
          account: await accountService.findAccount(
            id: senderid!,
          ));

      if (await accountStatusCheck(
        senderid,
      )) {
        addToPendingTransfer(
          senderid,
          recipientid,
          amount,
        );

        await changeAccountStatusToProcessing(
          senderid,
        );
      } else {
        throw PendingTransactionException();
      }
    }
  }

  Future addToPendingDeposit(
      String sender, String recipient, double amount) async {
    /// Edit User Account Balance
    /// String id - User P23 id
    /// String value - Transaction Value
    /// String transactionType - 0: Withdraw, 1: Deposit
    await pendingTansactions.add(TransactionRecord(
      sender: sender,
      recipient: recipient,
      amount: amount,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      transID: Uuid().v4(),
      transType: 1,
    ));
  }

  void addToPendingWithDraw(
      String sender, String recipient, double amount) async {
    /// Edit User Account Balance
    /// String id - User P23 id
    /// String value - Transaction Value
    /// String transactionType - 0: Withdraw, 1: Deposit
    await pendingTansactions.add(TransactionRecord(
      sender: sender,
      recipient: recipient,
      amount: amount,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      transID: Uuid().v4(),
      transType: 0,
    ));
  }

  void addToPendingTransfer(
      String sender, String recipient, double amount) async {
    //Allows users to transfer points between each other
    /// String transactionType - 0: Withdraw, 1: Deposit, 2: Transfer
    await pendingTansactions.add(TransactionRecord(
      sender: sender,
      recipient: recipient,
      amount: amount,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      transID: Uuid().v4(),
      transType: 2, //TODO: Change 0 and 1 to Deposit and Withdaw;
    ));
  }

  Future<bool> accountStatusCheck(String? sender) async {
    var foundAccount = await accountService.findAccount(
      id: sender!,
    );
    return foundAccount.status == 'normal';
  }

  Future<bool> accountPaymentValidation(String sender) async {
    bool accountValid;
    var foundAccount = await accountService.findAccount(
      id: sender,
    );

    if (foundAccount.id!.isNotEmpty) {
      accountValid = true;
    } else {
      accountValid = false;
    }

    return accountValid;
  }

  Future<bool> recipientValidation(
    String recipient,
  ) async {
    //Validates the reciepeinet of the reward has an account the system
    bool accountValid;
    var recipientAccount = await accountService.findAccount(
      id: recipient,
    );

    if (recipientAccount.id!.isNotEmpty) {
      //if the Account Server return an account it is a valid account
      accountValid = true;
    } else {
      //the Accout is not Valid
      accountValid = false;
    }

    return accountValid;
  }

  Future<void> changeAccountStatusToProcessing(String id) async {
    //Changes the Users Account Status to processing.
    await DatabaseService.client
        .from('accounts')
        .update({'status': 'processing'})
        .eq('id', id)
        .execute();
  }

  Future<void> changeClaimToTrue(String transID) async {
    await DatabaseService.client
        .from('rechargeNotifications')
        .update({'claimed': true})
        .eq('transID', transID)
        .execute();
  }

  Future<void> changeAccountStatusNormal(String? id) async {
    //Changes the Users Account Status to normal.
    await DatabaseService.client
        .from('accounts')
        .update({'status': 'normal'})
        .eq('id', id)
        .execute();
  }

  Future<Block> get lastBlock async {
    var response;
    try {
      response = await DatabaseService.client
          .from('blockchain')
          .select()
          .limit(1)
          .order('timestamp', ascending: false)
          .execute();
    } catch (e, trace) {
      print(trace);
      rethrow;
    }
    ;
    return Block.fromJson(response.data[0]);
  }

  List<TransactionRecord> get pendingTransactions {
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
    return HEX.encode(guessHash).substring(0, 4) == Env.difficulty;
  }

  Future<List<Block>> getBlockchain() async {
    //Todo Handling
    var jsonChain = <Block>[];
    var response = await DatabaseService.client
        .from('blockchain')
        .select()
        .limit(1)
        .order('timestamp', ascending: false)
        .execute();

    var chain = response.data as List;
    chain.forEach((element) {
      jsonChain.add(Block.fromJson(element));
    });

    return jsonChain;
  }

  String getPendingTransactions() {
    var jsonChain = [];
    pendingTansactions.values.forEach((element) {
      jsonChain.add(element.toJson());
    });
    json.encode(jsonChain);
    return jsonChain.toString();
  }
}
