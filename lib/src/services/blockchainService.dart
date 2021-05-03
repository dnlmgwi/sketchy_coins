import 'package:crypto/crypto.dart' as crypto;
import 'package:sketchy_coins/packages.dart';

class BlockchainService {
  DatabaseService databaseService;

  BlockchainService({required this.databaseService});

  var accountService = AccountService(databaseService: DatabaseService());
  var blockChainValidity = BlockChainValidationService();

  var pendingTansactions = Hive.box<TransactionRecord>('transactions');

  Future<Block> newBlock(int proof, String previousHash) async {
    var response;
    if (previousHash.isEmpty) {
      hash(Block.fromJson(response.data));
    }

    try {
      response = await databaseService.client
          .from('blockchain')
          .select()
          .limit(1)
          .order('timestamp', ascending: false)
          .execute();

      await databaseService.client.from('blockchain').insert(
        [
          Block(
            index: Block.fromJson(response.data[0]).index! + 1,
            timestamp: DateTime.now().millisecondsSinceEpoch,
            proof: proof,
            prevHash: previousHash,
            transactions: pendingTansactions.values.toList(),
            //If there is a duplicate transaction will ensure that there is no double deduction.
          ).toJson()
        ],
      ).execute();

      await processPayments().whenComplete(() => pendingTansactions.clear());
      //Successfully Mined

      if (response.error != null) {
        throw response.error!.message;
      }

      return Block.fromJson(response.data[0]);
    } on PostgrestError catch (e) {
      print(e.code);
      print(e.message);
      rethrow;
    }
  }

  Future processPayments() async {
    var response;
    try {
      response = await databaseService.client
          .from('blockchain')
          .select()
          .limit(1)
          .order('timestamp', ascending: false)
          .execute();
      if (DateTime.fromMillisecondsSinceEpoch(
              Block.fromJson(response.data[0]).timestamp)
          .isBefore(DateTime.now())) {
        pendingTansactions.values.forEach((element) async {
          Account? foundAccount;

          /// Edit User Account Balance
          /// String address - User Address
          /// String value - Transaction Value
          /// String transactionType - 0: Withdraw, 1: Deposit, 2: Transfer 3: Reversal
          if (element.transType == 1) {
            await depositProcess(foundAccount, element);
          } else {
            await withdrawProcess(foundAccount, element);
          }
        });
      }
      if (response.error != null) {
        throw response.error!.message;
      }
      // return response.data;
    } on PostgrestError catch (e) {
      print(e.code);
      print(e.message);
      rethrow;
    }
  }

  Future<Account> depositProcess(
      Account? foundAccount, TransactionRecord element) async {
    try {
      foundAccount = await accountService.findAccount(
        address: element.recipient,
      );

      await accountService.editAccountBalance(
          account: foundAccount,
          value: element.amount,
          transactionType: element.transType);
      changeAccountStatusNormal(foundAccount.address);
    } catch (e) {
      print('Failed Processing');
      rethrow;
    }
    return foundAccount;
  }

  Future<Account> withdrawProcess(
      Account? foundAccount, TransactionRecord element) async {
    try {
      foundAccount = await accountService.findAccount(address: element.sender);

      await accountService.editAccountBalance(
          account: foundAccount,
          value: element.amount,
          transactionType: element.transType);
      changeAccountStatusNormal(foundAccount.address);
    } catch (e) {
      print('Failed Processing');
      rethrow;
    }

    return foundAccount;
  }

  Future<void> initiateTransfer(
      {required String sender,
      required String recipient,
      required double amount}) async {
    if (await accountValidation(sender, recipient)) {
      //Check if the sender & recipient are in the account
      if (sender == recipient) {
        throw SelfTransferException();
      }
      accountService.checkAccountBalance(
          value: amount,
          account: await accountService.findAccount(
            address: sender,
          ));

      if (await accountStatusCheck(sender)) {
        addToPendingTransfer(sender, recipient, amount);
        changeAccountStatusToProcessing(sender);
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

  void addToPendingTransfer(String sender, String recipient, double amount) {
    //Allows users to transfer points between each other
    /// String transactionType - 0: Withdraw, 1: Deposit, 2: Transfer
    var transId = Uuid().v4();
    var timestamp = DateTime.now().millisecondsSinceEpoch;

    pendingTansactions.add(TransactionRecord(
      sender: sender,
      recipient: recipient,
      amount: amount,
      timestamp: timestamp,
      transID: transId,
      transType: 0, //TODO: Change 0 and 1 to Deposit and Withdaw;
    ));

    pendingTansactions.add(TransactionRecord(
      sender: sender,
      recipient: recipient,
      amount: amount,
      timestamp: timestamp,
      transID: transId,
      transType: 1,
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

  Future<bool> accountValidation(String sender, String recipient) async {
    late bool isValidAccount;
    await accountService
        .findAccounts(sender: sender, recipient: recipient)
        .then((value) {
      if (value.length == 1) {
        //If the lenght is equal to 1 it means both accounts
        //are not found this shouldn't allow the transaction
        //to happen its not a valid account Provided.
        isValidAccount = false;
      } else if (value.length == 2) {
        //Else both accounts are in the system this tansaction
        //can proceed.
        isValidAccount = true;
      }
    });

    return isValidAccount;
    //FindBothAccounts
  }

  //TODO Future<void> newMineTransaction({
  //   required String recipient,
  //   required double amount,
  // }) async {
  //   //Check if the recipient is in the system if not an no reward is provided
  //   // if (await recipientValidation(recipient)) {
  //   //   //Change the account to processing to prevent any overdraft issues.
  //   //   changeAccountStatusToProcessing(recipient);
  //   //   addToPendingDeposit(Env.systemAddress, recipient, amount);
  //   // }
  // }

  Future rechargeAccount({
    required String recipient,
    required String transID,
  }) async {
    //Check if the recipient is in the system if not an no reward is provided
    //Check if TransID and Amount match the recieved notification.
    if (await recipientValidation(recipient)) {
      try {
        var data = await findTransID(transID: transID);
        //Change the account to processing to prevent any overdraft issues.
        //TODO Change Recharge notification to Claimed true to provent muliple claims.
        changeAccountStatusToProcessing(recipient);
        addToPendingDeposit('MobileMoney: ${data['transID']}', recipient,
            double.parse(extractAmount(data)));
        return {
          'message': 'Transaction Verified',
          'recipient': recipient,
          'amount': extractAmount(data)
        };
      } catch (e) {
        rethrow;
      }
    }
  }

  String extractAmount(data) => data['amount'].toString().split('MK').last;

  Future findTransID({required String transID}) async {
    var response = await databaseService.client
        .from('rechargeNotifications')
        .select()
        .eq('transID', transID)
        .limit(1)
        .execute()
        .onError(
          (error, stackTrace) => throw Exception(error),
        );
    if (response.data[0]['claimed']) {
      throw TransIDClaimedException();
    }
    changeClaimToTrue(transID);

    if (response.data == null) {
      throw TransIDNotFoundException();
    }

    response.data as List;

    return response.data[0];
  }

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
    await accountService.databaseService.client
        .from('accounts')
        .update({'status': 'processing'})
        .eq('address', address)
        .execute();
  }

  void changeClaimToTrue(String transID) async {
    //Changes the Users Account Status to processing.
    await accountService.databaseService.client
        .from('rechargeNotifications')
        .update({'claimed': true})
        .eq('transID', transID)
        .execute();
  }

  void changeAccountStatusNormal(String address) async {
    //Changes the Users Account Status to normal.
    await accountService.databaseService.client
        .from('accounts')
        .update({'status': 'normal'})
        .eq('address', address)
        .execute();
  }

  Future<Block> get lastBlock async {
    var response = await databaseService.client
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
    var response = await databaseService.client
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
