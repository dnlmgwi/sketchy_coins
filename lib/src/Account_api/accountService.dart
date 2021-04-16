import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:hive/hive.dart';
import 'package:sketchy_coins/src/Account_api/accountExeptions.dart';
import 'package:sketchy_coins/src/Auth_api/EnvValues.dart';
import 'package:sketchy_coins/src/Models/Account/account.dart';

class AccountService {
  final _accountList = Hive.box<Account>('accounts');

  Account findAccount(
      {required Box<Account> accounts, required String address}) {
    return accounts.values.firstWhere((element) => element.address == address,
        orElse: () => throw AccountNotFoundException());
  }

  Account findDuplicateAccount(
      {required Box<Account> accounts, required String address}) {
    return accounts.values.firstWhere(
      (element) => element.address == address,
      orElse: () => throw AccountDuplicationException(),
    );
  }

  bool validateAccount({
    required String pin,
    required String number,
  }) {
    var duplicateAccount = false;
    try {
      findAccount(accounts: _accountList, address: identityHash('$pin$number'));
    } catch (e) {
      duplicateAccount = true;
      print('Error ${e.toString()}');
    }
    return duplicateAccount;
  }

  void createAccount({
    required String pin,
    required String number,
  }) {
    if (validateAccount(pin: pin, number: number)) {
      _accountList.add(
        Account(
          status: 'normal',
          address: identityHash('$pin$number'),
          balance: enviromentVariables.newAccountBalance,
        ),
      );
    } else {
      throw AccountDuplicationException();
    }
  }

  String identityHash(String data) {
    var key = utf8.encode('psalms23');
    var bytes = utf8.encode(data);

    var hmacSha256 = Hmac(sha256, key); // HMAC-SHA256
    var digest = hmacSha256.convert(bytes);

    return digest.toString().split('-').first;
  }

  /// Edit User Account Balance
  /// String address - User P23 Address
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
      } else if (value < enviromentVariables.minTransactionAmount) {
        throw InvalidInputException();
      }
    } catch (e) {
      rethrow;
    }

    account.balance = account.balance - value;
    account.save();

    return account.balance;
  }

  double checkAccountBalance(
      {required double value, required Account account}) {
    try {
      if (value > account.balance) {
        throw InsufficientFundsException();
      } else if (value < enviromentVariables.minTransactionAmount) {
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
}
