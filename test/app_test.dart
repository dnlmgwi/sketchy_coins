import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:sketchy_coins/blockchain.dart';
import 'package:sketchy_coins/src/Account_api/accountExeptions.dart';
import 'package:sketchy_coins/src/Account_api/accountService.dart';
import 'package:sketchy_coins/src/Blockchain_api/miner.dart';
import 'package:sketchy_coins/src/Blockchain_api/blockchainValidation.dart';
import 'package:sketchy_coins/src/Models/Account/account.dart';
import 'package:sketchy_coins/src/Models/mineResult/mineResult.dart';
import 'package:sketchy_coins/src/Models/transaction/transaction.dart';
import 'package:test/test.dart';

void main() async {
  Hive.init('kkoin_test');
  Hive.registerAdapter(AccountAdapter());
  Hive.registerAdapter(BlockAdapter());
  Hive.registerAdapter(MineResultAdapter());
  Hive.registerAdapter(TransactionAdapter());

  await Hive.openBox<Block>('blockchain');
  await Hive.openBox<Account>('accounts');
  await Hive.openBox<Transaction>('transactions');
  var blockchainService = BlockchainService();
  var a = BlockChainValidity();
  var miner = Miner(blockchainService);
  var accountService = AccountService();
  group('Blockchain', () {
    test('Test', () {
      expect(blockchainService, isNotNull);
      var blockIndex = blockchainService.newTransaction(
          sender: 'john', recipient: 'steve', amount: 0.50);

      expect(blockIndex, blockchainService.blockchainStore.length);
      blockchainService.blockchainStore.values.forEach((element) {
        print(element.toJson());
      });
    });
  });
  group('Block', () {
    test('json encode', () {
      var b = Block(
          index: 0, prevHash: 'sdsd', proof: 0, timestamp: 0, transactions: []);
      var r = json.encode(b);
      expect(r, isNotNull);
    });
  });

  group('Account_Api', () {
    test(
      'New Account',
      () {
        expect(accountService.createAccount().values.last.address, isNotNull);
      },
    );

    test('List Accounts', () {
      expect(accountService.accountList.values, isNotNull);
      print(accountService.accountList.values.last.address);
    });

    test(
      'Find Account',
      () {
        var account = accountService.findAccount(
            data: accountService.accountList,
            address: 'b8cadbee-2fed-44f5-abca-1f163c05abdc');
        expect(account.toJson(), {
          'address': 'b8cadbee-2fed-44f5-abca-1f163c05abdc',
          'status': 'normal',
          'balance': 566.0,
          'transactions': []
        });
      },
    );

    test(
      'Account Not Found',
      () {
        try {
          var account = accountService.findAccount(
              data: accountService.accountList,
              address: 'bcb7a14f8-0eb3-4ec7-9399-975b89ba65a8');
          expect(account, account.toString());
        } on AccountNotFoundException catch (e) {
          print('Error: ${e.toString()}');
        }
      },
    );

    test(
      'Account Deposit',
      () {
        var account;
        print(
            'Before: ${accountService.findAccount(data: accountService.accountList, address: 'b8cadbee-2fed-44f5-abca-1f163c05abdc').toJson()}');
        expect(
            account = accountService.deposit(
                account: accountService.findAccount(
                    data: accountService.accountList,
                    address: 'b8cadbee-2fed-44f5-abca-1f163c05abdc'),
                value: 1000000),
            account);

        print('After: $account');
      },
    );

    test(
      'New Withdraw Fail',
      () {
        try {
          expect(
              accountService.withdraw(
                  account: accountService.findAccount(
                      data: accountService.accountList,
                      address: 'b8cadbee-2fed-44f5-abca-1f163c05abdc'),
                  value: 0.3),
              accountService
                  .findAccount(
                      data: accountService.accountList,
                      address: 'b8cadbee-2fed-44f5-abca-1f163c05abdc')
                  .balance);
        } on InsufficientFundsException catch (e) {
          print(e.toString());
        } on InvalidInputException catch (e) {
          print(e.toString());
        }
      },
    );

    test(
      'Account Not Found',
      () {
        try {
          expect(
              accountService.findAccount(
                  data: accountService.accountList,
                  address: 'ncb7a14f8-0eb3-4ec7-9399-975b89ba65a8'),
              AccountNotFoundException().toString());
        } on AccountNotFoundException catch (e) {
          print(e.toString());
        }
      },
    );

    test(
      'New Withdraw Fail',
      () {
        var account;
        print('Before: ${accountService.accountList.values.first.balance}');
        try {
          expect(
              account = accountService.withdraw(
                  account: accountService.findAccount(
                      data: accountService.accountList,
                      address: 'b8cadbee-2fed-44f5-abca-1f163c05abdc'),
                  value: 0.3),
              account);
          print('After: $account');
        } on InsufficientFundsException catch (e) {
          print(e.toString());
        }
      },
    );

    test(
      'New Withdraw Pass',
      () {
        var account;
        print(accountService.accountList.values.first.address);
        print('Before: ${accountService.accountList.values.first.balance}');
        expect(
            account = accountService.withdraw(
                account: accountService.findAccount(
                    data: accountService.accountList,
                    address: 'b8cadbee-2fed-44f5-abca-1f163c05abdc'),
                value: 100),
            account);

        print('After: $account');
      },
    );
  });
  group('Miner', () {
    test('Test', () {
      var result = miner.mine(address: 'cb7a14f8-0eb3-4ec7-9399-975b89ba65a8');
      expect(result, isNotNull);
      expect(result.containsKey('prevHash'), isNotNull);
      blockchainService.newTransaction(
          sender: 'cb7a14f8-0eb3-4ec7-9399-975b89ba65a8',
          recipient: '0',
          amount: 1.50);
      var isValid = a.isFirstBlockValid(
          chain: miner.blockchain.blockchainStore,
          blockchainService: blockchainService);
      expect(isValid, true);

      var result2 = a.isBlockChainValid(
          chain: blockchainService.blockchainStore,
          blockchain: blockchainService);

      expect(result2, isNotNull);
      expect(result2, true);
    });
  });
}
// group('Account', () {
// var accountService = AccountService();
// test('Found', () {
//   final account = accountService.findAccount(
//     data: accountService.accountList,
//     address: '89sdc89',
//   );
//   expect(account, isNotNull);
// });

// test('Find Error ', () {
//   expect(
//     accountService.findAccount(
//       data: accountService.accountList,
//       address: '89sdcjj89',
//     ),
//     null,
//   );
// });

// test('Insufficient funds', () {
//   expect(
//       accountService.editAccountBalance(
//           address: '8nj9ssdcs89', value: 10434.5, transactionType: 0),
//       isNull);
// });

// test('Not Found', () {
//   expect(
//       accountService.editAccountBalance(
//           address: '8scdcs989ff', value: 434.5, transactionType: 1),
//       isNull);
// });

//   test('Withdraw', () {
//     Iterable l = json.decode(
//       File('accounts.json').readAsStringSync(),
//     );

//     var accounts =
//         List<Account>.from(l.map((model) => Account.fromJson(model)));

//     print(accounts);

//     expect(accountService.withdraw(account: , value: ), 2324);
//   });

//   test('Deposit', () {
//     expect(accountService.withdraw(value, account), 2324);
//   });
// });

//   group('Blockchain Validation', () {
//     test('isFirstBlockValid', () {
//       var result = a.isFirstBlockValid(chain: b.getFullChain(), blockchain: b);
//       expect(result, isNotNull);
//       expect(result, true);
//     });

//     test('isBlockChainValid', () {
//       var result = a.isBlockChainValid(chain: b.getFullChain(), blockchain: b);
//       expect(result, isNotNull);
//       expect(result, true);
//     });

//     test('isValidNewBlock', () {
//       expect(
//           a.isValidNewBlock(
//               previousBlock: miner.blockchain.getFullChain().last,
//               newBlock: miner.blockchain.getFullChain().first,
//               blockchain: b),
//           true);
//     });
//   });
// }
