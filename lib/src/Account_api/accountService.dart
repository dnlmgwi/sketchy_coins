import 'dart:math';
import 'package:hive/hive.dart';
import 'package:sketchy_coins/src/Account_api/accountExeptions.dart';
import 'package:sketchy_coins/src/Blockchain_api/kkoin.dart';
import 'package:sketchy_coins/src/Models/Account/account.dart';
import 'package:uuid/uuid.dart';

class AccountService {
  final _accountList = Hive.box<Account>('accounts');

  Account findAccount({required Box<Account> data, required String address}) {
    return data.values.firstWhere((element) => element.address == address,
        orElse: () => throw AccountNotFoundException());
  }

  Box<Account> createAccount() {
    var balance = Random();

    _accountList.add(
      Account(
          status: 'normal',
          address: Uuid().v4(),
          balance: balance.nextInt(1000).toDouble(),
          transactions: []),
    );

    print('New Account: ${_accountList.values.first}');
    return _accountList;
  }

  /// Edit User Account Balance
  /// String address - User Koin Address
  /// String value - Transaction Value
  /// String transactionType - 0: Withdraw, 1: Deposit
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
        }
      } else if (operation == 1) {
        return deposit(account: account, value: value);
      }
    } on AccountNotFoundException catch (e) {
      print(e);
    }
    return account.balance;
  }

  double deposit({required Account account, required double value}) =>
      account.balance + value;

  double withdraw({required double value, required Account account}) {
    try {
      if (value > account.balance) {
        throw InsufficientFundsException();
      } else if (value < kKoin.minAmount) {
        throw InvalidInputException();
      }
    } catch (e) {
      return account.balance;
    }

    return account.balance - value;
  }

  Box<Account> get accountList {
    return _accountList;
  }
}
