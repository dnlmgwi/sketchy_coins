import 'package:sketchy_coins/packages.dart';

class AccountService {
  final _accountList = Hive.box<Account>('accounts');

  Account findAccount({
    required Box<Account> accounts,
    required String address,
  }) {
    return accounts.values.firstWhere((element) => element.address == address,
        orElse: () => throw AccountNotFoundException());
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

  Box<Account> get accountList {
    return _accountList;
  }

  int get accountListCount {
    return _accountList.values.length;
  }
}
