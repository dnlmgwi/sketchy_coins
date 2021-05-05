import 'package:crypto/crypto.dart' as crypto;
import 'package:sketchy_coins/packages.dart';
import 'package:supabase/supabase.dart';

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
      ;

      await processPayments().onError((error, stackTrace) =>
          throw Exception(' Error: $error StackTrace: $stackTrace'));
      //Successfully Mined

      await DatabaseService.client.from('blockchain').insert(
        [
          Block(
            index: Block.fromJson(prevBlock.data[0]).index! + 1,
            timestamp: DateTime.now().millisecondsSinceEpoch,
            proof: proof,
            prevHash: previousHash,
            transactions: List.from(pendingTansactions.values.toList()),
          ).toJson()
        ],
      ).execute();

      if (prevBlock.error != null) {
        throw prevBlock.error!.message;
      }

      var latestBlock = await DatabaseService.client
          .from('blockchain')
          .select()
          .limit(1)
          .order('timestamp', ascending: false)
          .execute()
          .whenComplete(
            () => pendingTansactions.clear(),
          );

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
        for (var transaction
            in pendingTansactions.values.toList(growable: true)) {
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
              .insert([transaction.toJson()]).execute();
        }

        // pendingTansactions.values.forEach((element) async {
        //   /// Edit User Account Balance
        //   /// String address - User Address
        //   /// String value - Transaction Value
        //   /// String transactionType - 0: Withdraw, 1: Deposit, 2: Transfer 3: Reversal
        //   switch (element.transType) {
        //     case 0:
        //       await withdrawProcess(element);
        //       break;
        //     case 1:
        //       await depositProcess(element);
        //       break;

        //     case 2:
        //       await transferProcess(element);
        //       break;
        //   }
        // });
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
        address: element.recipient,
      );

      await editAccountBalance(
          senderAccount: foundAccount,
          value: element.amount,
          transactionType: element.transType);
      changeAccountStatusNormal(foundAccount.address);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> withdrawProcess(TransactionRecord element) async {
    try {
      var foundAccount =
          await accountService.findAccount(address: element.sender);

      var response = await editAccountBalance(
              senderAccount: foundAccount,
              value: element.amount,
              transactionType: element.transType)
          .whenComplete(() => changeAccountStatusNormal(foundAccount.address));

      print('S $response');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> transferProcess(TransactionRecord element) async {
    try {
      var recipientAccount = await accountService.findAccount(
        address: element.recipient,
      );

      var senderAccount = await accountService.findAccount(
        address: element.sender,
      );

      /// Edit User Account Balance
      /// String address - User P23 Address
      /// String value - Transaction Value
      /// String transactionType - 0: Withdraw, 1: Deposit
      ///
      await editAccountBalance(
        senderAccount: senderAccount,
        recipientAccount: recipientAccount,
        value: element.amount,
        transactionType: element.transType,
      );

      changeAccountStatusNormal(senderAccount.address);
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
          .eq('address', account.address)
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
          .eq('address', senderAccount.address)
          .execute();

      await DatabaseService.client
          .from('accounts')
          .update({'balance': recipientAccount.balance + value})
          .eq('address', recipientAccount.address)
          .execute();
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
            .eq('address', account.address)
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
      if (await accountStatusCheck(account.address)) {
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

  // Future recharge({
  //   required String recipient,
  //   required String transID,
  // }) async {
  //   var response;
  //   try {
  //     response = await rechargeAccount(
  //       recipient: recipient,
  //       transID: transID,
  //     );
  //   } catch (e) {
  //     rethrow;
  //   }
  //   return response;
  // }

  Future recharge({required Box<RechargeNotification> data}) async {
    try {
      //Check if TransID and Amount match the recieved notification.
      print(data.values.length);

      for (var item in data.values) {
        var account = await accountService.findDepositAccount(
            phoneNumber: item.phoneNumber);

        try {
          //Change the account to processing to prevent any overdraft issues.

          addToPendingDeposit(item.transID, account.address,
              double.parse(item.amount.toString().split('MK').last));
          changeClaimToTrue(item.transID);
          changeAccountStatusToProcessing(account.address);
          await item.delete();
        } catch (e) {
          rethrow;
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> initiateTransfer({
    required String senderAddress,
    required String recipientAddress,
    required double amount,
  }) async {
    if (await recipientValidation(recipientAddress)) {
      //Check if the sender & recipient are in the system
      if (senderAddress == recipientAddress) {
        //Prevents User from Sending Points To Self Compounding Account Balance.
        throw SelfTransferException();
      }
      await checkAccountBalance(
          value: amount,
          account: await accountService.findAccount(
            address: senderAddress,
          ));

      if (await accountStatusCheck(
        senderAddress,
      )) {
        addToPendingTransfer(
          senderAddress,
          recipientAddress,
          amount,
        );
        //Blocks User from Muliple Transactions As Account Balance Will no be uptoDate till after it has been proccessed
        changeAccountStatusToProcessing(
          senderAddress,
        ); //TODO This Prevents Overdarfting
      } else {
        throw PendingTransactionException();
      }
    }
  }

  void addToPendingDeposit(String sender, String recipient, double amount) {
    /// Edit User Account Balance
    /// String address - User P23 Address
    /// String value - Transaction Value
    /// String transactionType - 0: Withdraw, 1: Deposit
    pendingTansactions.add(TransactionRecord(
      sender: sender,
      recipient: recipient,
      amount: amount,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      transID: Uuid().v4(),
      transType: 1,
    ));
  }

  void addToPendingWithDraw(String sender, String recipient, double amount) {
    /// Edit User Account Balance
    /// String address - User P23 Address
    /// String value - Transaction Value
    /// String transactionType - 0: Withdraw, 1: Deposit
    pendingTansactions.add(TransactionRecord(
      sender: sender,
      recipient: recipient,
      amount: amount,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      transID: Uuid().v4(),
      transType: 0,
    ));
  }

  void addToPendingTransfer(String sender, String recipient, double amount) {
    //Allows users to transfer points between each other
    /// String transactionType - 0: Withdraw, 1: Deposit, 2: Transfer
    pendingTansactions.add(TransactionRecord(
      sender: sender,
      recipient: recipient,
      amount: amount,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      transID: Uuid().v4(),
      transType: 2, //TODO: Change 0 and 1 to Deposit and Withdaw;
    ));
  }

  Future<bool> accountStatusCheck(String sender) async {
    var foundAccount = await accountService.findAccount(
      address: sender,
    );
    return foundAccount.status == 'normal';
  }

  Future<bool> accountPaymentValidation(String sender) async {
    bool accountValid;
    var foundAccount = await accountService.findAccount(
      address: sender,
    );

    if (foundAccount.address.isNotEmpty) {
      accountValid = true;
    } else {
      accountValid = false;
    }

    return accountValid;
  }

  // Future rechargeAccount({
  //   required String recipient,
  //   required String transID,
  // }) async {
  //   //Check if the recipient is in the system if not an no reward is provided
  //   //Check if TransID and Amount match the recieved notification.
  //   if (await recipientValidation(recipient)) {
  //     try {
  //       var data = await findTransID(transID: transID);
  //       //Change the account to processing to prevent any overdraft issues.
  //       if (await accountStatusCheck(recipient)) {
  //         addToPendingDeposit(
  //             data['transID'], recipient, double.parse(extractAmount(data)));
  //         changeClaimToTrue(transID);
  //         changeAccountStatusToProcessing(recipient);
  //       } else {
  //         throw PendingTransactionException();
  //       }

  //       return {
  //         'message': 'Payment Verified',
  //         'recipient': recipient,
  //         'amount': extractAmount(data)
  //       };
  //     } catch (e) {
  //       rethrow;
  //     }
  //   }
  // }

  Future<bool> recipientValidation(
    String recipient,
  ) async {
    //Validates the reciepeinet of the reward has an account the system
    bool accountValid;
    var recipientAccount = await accountService.findAccount(
      address: recipient,
    );

    if (recipientAccount.address.isNotEmpty) {
      //if the Account Server return an account it is a valid account
      accountValid = true;
    } else {
      //the Accout is not Valid
      accountValid = false;
    }

    return accountValid;
  }

  void changeAccountStatusToProcessing(String address) async {
    //Changes the Users Account Status to processing.
    await DatabaseService.client
        .from('accounts')
        .update({'status': 'processing'})
        .eq('address', address)
        .execute();
  }

  void changeClaimToTrue(String transID) async {
    await DatabaseService.client
        .from('rechargeNotifications')
        .update({'claimed': true})
        .eq('transID', transID)
        .execute();
  }

  void changeAccountStatusNormal(String address) async {
    //Changes the Users Account Status to normal.
    await DatabaseService.client
        .from('accounts')
        .update({'status': 'normal'})
        .eq('address', address)
        .execute();
  }

  Future<Block> get lastBlock async {
    var response = await DatabaseService.client
        .from('blockchain')
        .select()
        .limit(1)
        .order('timestamp', ascending: false)
        .execute();
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

  String extractAmount(data) => data['amount'].toString().split('MK').last;

  String getPendingTransactions() {
    var jsonChain = [];
    pendingTansactions.values.forEach((element) {
      jsonChain.add(element.toJson());
    });
    json.encode(jsonChain);
    return jsonChain.toString();
  }
}
