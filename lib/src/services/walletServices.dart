import 'package:sketchy_coins/packages.dart';

class WalletService implements IWalletService {
  var accountService = AccountService(databaseService: DatabaseService());
  var pendingTansactions = Hive.box<TransactionRecord>('transactions');
  var pendingDepositsTansactions =
      Hive.box<RechargeNotification>('rechargeNotifications');

  @override
  Future<void> processPayments() async {
    try {
      var response = await DatabaseService.client
          .from('blockchain')
          .select()
          .limit(1)
          .order('timestamp', ascending: false)
          .execute();

      // if (response.data == null) {}
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

  @override
  Future<void> depositProcess(TransactionRecord element) async {
    try {
      var foundAccount = await accountService.findAccountDetails(
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

  @override
  Future<void> withdrawProcess(TransactionRecord element) async {
    try {
      var foundAccount =
          await accountService.findAccountDetails(id: element.sender);

      await editAccountBalance(
          senderAccount: foundAccount,
          value: element.amount,
          transactionType: element.transType);
      await changeAccountStatusNormal(foundAccount.id);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> transferProcess(TransactionRecord element) async {
    try {
      var recipientAccount = await accountService.findAccountDetails(
        id: element.recipient,
      );

      var senderAccount = await accountService.findAccountDetails(
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

  @override
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

  @override
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

  @override
  Future<void> transfer({
    required double value,
    required TransAccount senderAccount,
    required TransAccount recipientAccount,
  }) async {
    try {
      await DatabaseService.client
          .from('accounts')
          .update({
            'balance': senderAccount.balance - value,
          })
          .eq('id', senderAccount.id)
          .execute()
          .then((_) => DatabaseService.client
              .from('accounts')
              .update({
                'balance': recipientAccount.balance + value,
                'lastTrans': DateTime.now().millisecondsSinceEpoch
              })
              .eq('id', recipientAccount.id)
              .execute());
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> withdraw({
    required double value,
    required TransAccount account,
  }) async {
    //TODO: External Provider Withdraw Provider Needed
    try {
      if (value > account.balance) {
        throw InsufficientFundsException();
      } else if (value < double.parse(Env.minTransactionAmount!)) {
        throw InvalidInputException();
      } else {
        await DatabaseService.client
            .from('accounts')
            .update({
              'balance': account.balance - value,
            })
            .eq('id', account.id)
            .execute();
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<double> checkAccountBalance({
    required double value,
    required TransAccount account,
  }) async {
    try {
      if (await accountStatusCheck(account.id!)) {
        if (value > account.balance) {
          throw InsufficientFundsException();
        } else if (value < double.parse(Env.minTransactionAmount!)) {
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

  @override
  Future initiateTopUp({required Box<RechargeNotification> data}) async {
    try {
      //Check if TransID and Amount match the recieved notification.
      print('Total Items: ${data.values.length}');

      for (var item in data.values) {
        await accountService
            .findRecipientDepositAccount(phoneNumber: item.phoneNumber)
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

  @override
  double extractAmount(RechargeNotification item) =>
      double.parse(item.amount.toString().split('MK').last);

  @override
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
          account: await accountService.findAccountDetails(
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

  @override
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

  @override
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

  @override
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

  @override
  Future<bool> accountStatusCheck(String? sender) async {
    var foundAccount = await accountService.findAccountDetails(
      id: sender!,
    );
    return foundAccount.status == 'normal';
  }

  @override
  Future<bool> accountPaymentValidation(String sender) async {
    bool accountValid;
    var foundAccount = await accountService.findAccountDetails(
      id: sender,
    );

    if (foundAccount.id!.isNotEmpty) {
      accountValid = true;
    } else {
      accountValid = false;
    }

    return accountValid;
  }

  @override
  Future<bool> recipientValidation(
    String recipient,
  ) async {
    //Validates the reciepeinet of the reward has an account the system
    bool accountValid;

    try {
      var recipientAccount = await accountService.findAccountDetails(
        id: recipient,
      );

      //TODO: If Recent Transaction was made throw please wait x minutes

      if (recipientAccount.id!.isNotEmpty) {
        //if the Account Server return an account it is a valid account
        accountValid = true;
      } else {
        //the Accout is not Valid
        accountValid = false;
      }

      return accountValid;
    } on RecentTransException catch (e) {
      throw '$e';
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> changeAccountStatusToProcessing(String id) async {
    //Changes the Users Account Status to processing.
    await DatabaseService.client
        .from('accounts')
        .update({
          'status': 'processing',
          'lastTrans': DateTime.now().millisecondsSinceEpoch
        })
        .eq('id', id)
        .execute();
  }

  @override
  Future<void> changeClaimToTrue(String transID) async {
    await DatabaseService.client
        .from('rechargeNotifications')
        .update({'claimed': true})
        .eq('transID', transID)
        .execute();
  }

  @override
  Future<void> changeAccountStatusNormal(String? id) async {
    //Changes the Users Account Status to normal.
    await DatabaseService.client
        .from('accounts')
        .update({'status': 'normal'})
        .eq('id', id)
        .execute();
  }
}
