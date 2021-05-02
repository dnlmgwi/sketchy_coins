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

  double editAccountBalance({
    required Account account,
    required double value,
    required int transactionType,
  }) {
    try {
      var operation = transactionType;

      if (operation == 0) {
        try {
          return withdraw(account: account, value: value);
        } on InsufficientFundsException catch (e) {
          print(e.toString());
          //Rethrow the Exception as it will be caught in API Call.
          rethrow;
        }
      } else if (operation == 1) {
        return deposit(account: account, value: value);
      }
    } on AccountNotFoundException catch (e) {
      print(e.toString());
      rethrow;
    }
    return account.balance;
  }

  double deposit({required Account account, required double value}) {
    account.balance = account.balance + value;
    account.save();
    return account.balance;
  }

  double withdraw({required double value, required Account account}) {
    try {
      if (value > account.balance) {
        throw InsufficientFundsException();
      } else if (value < double.parse(Env.minTransactionAmount)) {
        throw InvalidInputException();
      }
    } catch (e) {
      rethrow;
    }

    account.balance = account.balance - value;
    account.save();

    return account.balance;
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
