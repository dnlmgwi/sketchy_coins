// import 'dart:convert';
// import 'dart:io';
// import 'package:sketchy_coins/src/Account_api/accountExeptions.dart';
// import 'package:sketchy_coins/src/Models/Account/account.dart';

// class AccountService {
//   static Map<String, dynamic> accountMap = json.decode(
//     File('accounts.json').readAsStringSync(),
//   );

//   var account = Account.fromJson(
//     accountMap,
//   );

//   Account findAccount({required List data, required String address}) {
//     return data.firstWhere((account) => account['address'] == address,
//         orElse: () => null);
//   }

//   /// Edit User Account Balance
//   /// String address - User Koin Address
//   /// String value - Transaction Value
//   /// String transactionType - 0: Withdraw, 1: Deposit
//   // dynamic editAccountBalance({
//   //   required String address,
//   //   required double value,
//   //   required int transactionType,
//   // }) {
//   //   try {
//   //     var account = findAccount(data: _accountList, address: address);
//   //     var operation = transactionType;

//   //     if (account != null) {
//   //       if (operation == 0) {
//   //         try {
//   //           return withdraw(value, account);
//   //         } catch (e) {
//   //           print(e);
//   //         }
//   //       } else if (operation == 1) {
//   //         return deposit(account, value);
//   //       } else {
//   //         AccountNotFoundException();
//   //       }
//   //     }
//   //   } catch (e) {
//   //     print(e);
//   //   }
//   // }

//   double deposit(account, double value) => account['balance'] + value;

//   double withdraw({required double value, required Account account}) {
//     if (value > account.balance) {
//       throw InsufficientFundsException();
//     }
//     return account.balance - value;
//   }

//   List get accountList {
//     return account;
//   }
// }

// AccountService accountService = AccountService();
