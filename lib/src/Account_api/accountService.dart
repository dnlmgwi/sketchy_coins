import 'dart:math';

import 'package:hive/hive.dart';
import 'package:sketchy_coins/src/Account_api/accountExeptions.dart';
import 'package:sketchy_coins/src/Models/Account/account.dart';
import 'package:uuid/uuid.dart';

class AccountService {
  final _accountList = Hive.box<Account>('accounts');

  Account _findAccount({required Box<Account> data, required String address}) {
    return data.values.firstWhere((element) => element.address == address);
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
  dynamic editAccountBalance({
    required String address,
    required double value,
    required int transactionType,
  }) {
    try {
      var account = _findAccount(data: _accountList, address: address);
      var operation = transactionType;

      if (operation == 0) {
        try {
          return withdraw(account: account, value: value);
        } on InsufficientFundsException catch (e) {
          return e.toString();
        }
      } else if (operation == 1) {
        return deposit(account: account, value: value);
      }
    } catch (e) {
      print(e);
    }
  }

  double deposit({required Account account, required double value}) =>
      account.balance + value;

  double withdraw({required double value, required Account account}) {
    try {
      if (value > account.balance) {
        throw InsufficientFundsException();
      }
    } catch (e) {
      return account.balance;
    }

    return account.balance - value;
  }

  List<Account> get accountList {
    return _accountList.values.toList();
  }
}

// AccountService accountService = AccountService();
