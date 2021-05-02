import 'package:sketchy_coins/packages.dart';

class AccountService {
  DatabaseService databaseService;
  AccountService({required this.databaseService});

  Future<Account> findAccount({required String address}) async {
    var response = await databaseService.client
        .from('accounts')
        .select(
          'id,email,phoneNumber,password, salt,status,balance,joinedDate, address',
        )
        .match({
          'address': address,
        })
        .execute()
        .onError(
          (error, stackTrace) => throw Exception(error),
        );

    var result = response.data as List;

    if (result.isEmpty) {
      throw AccountNotFoundException();
    }

    return Account.fromJson(response.data[0]);
  }

  Future<List> findAccounts({
    required String recipient,
    required String sender,
  }) async {
    var response = await databaseService.client
        .from('accounts')
        .select(
          'address',
        )
        .in_('address', ['$sender', '$recipient'])
        .execute()
        .onError(
          (error, stackTrace) => throw Exception(error),
        );

    var result = response.data as List;

    if (result.isEmpty) {
      throw AccountNotFoundException();
    }

    return result;
  }

  Future editAccountBalance({
    required Account account,
    required double value,
    required int transactionType,
  }) async {
    try {
      var operation = transactionType;

      if (operation == 0) {
        try {
          return await withdraw(account: account, value: value);
        } on InsufficientFundsException catch (e) {
          print(e.toString());
          //Rethrow the Exception as it will be caught in API Call.
          rethrow;
        }
      } else if (operation == 1) {
        return await deposit(account: account, value: value);
      }
    } on AccountNotFoundException catch (e) {
      print(e.toString());
      rethrow;
    }
    return account.balance;
  }

  Future deposit({
    required double value,
    required Account account,
  }) async {
    PostgrestResponse response;
    try {
      response = await databaseService.client
          .from('accounts')
          .update({'balance': account.balance + value})
          .eq('address', account.address)
          .execute();
      print(response.data);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future withdraw({
    required double value,
    required Account account,
  }) async {
    try {
      PostgrestResponse response;
      if (value > account.balance) {
        throw InsufficientFundsException();
      } else if (value < double.parse(Env.minTransactionAmount)) {
        throw InvalidInputException();
      }

      response = await databaseService.client
          .from('accounts')
          .update({'balance': account.balance - value})
          .eq('address', account.address)
          .execute();
      print(response.data);
    } catch (e) {
      rethrow;
    }
  }

  double checkAccountBalance({
    required double value,
    required Account account,
  }) {
    try {
      if (value > account.balance) {
        throw InsufficientFundsException();
      } else if (value < double.parse(Env.minTransactionAmount)) {
        throw InvalidInputException();
      }
    } catch (e) {
      rethrow;
    }

    return account.balance;
  }
}
