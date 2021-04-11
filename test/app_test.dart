import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:sketchy_coins/blockchain.dart';
import 'package:sketchy_coins/src/Blockchain_api/miner.dart';
import 'package:sketchy_coins/src/Blockchain_api/blockchainValidation.dart';
import 'package:sketchy_coins/src/Models/Account/account.dart';
import 'package:sketchy_coins/src/Models/mineResult/mineResult.dart';
import 'package:sketchy_coins/src/Models/newTransaction/transactionPost.dart';
import 'package:sketchy_coins/src/Models/transaction/transaction.dart';
import 'package:test/test.dart';

void main() async {
  Hive.init('kkoin');
  Hive.registerAdapter(AccountAdapter());
  Hive.registerAdapter(BlockAdapter());
  Hive.registerAdapter(MineResultAdapter());
  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(TransactionPostAdapter());

  await Hive.openBox<Block>('blockchain');
  await Hive.openBox<Transaction>('transactions');
  var b = Blockchain();
  var a = BlockChainValidity();
  var miner = Miner(b);
  group('Blockchain', () {
    test('Test', () {
      expect(b, isNotNull);
      var blockIndex =
          b.newTransaction(sender: 'john', recipient: 'steve', amount: 0.50);

      expect(blockIndex, b.blockchain.length);
      b.blockchain.values.forEach((element) {
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
  group('Miner', () {
    test('Test', () {
      var result = miner.mine(address: 'csdcsdcd');
      expect(result, isNotNull);
      expect(result.containsKey('prevHash'), isNotNull);
      b.newTransaction(sender: 'steve', recipient: 'john', amount: 1.50);
      var isValid = a.isFirstBlockValid(
          chain: miner.blockchain.blockchain.values.toList(), blockchain: b);
      expect(isValid, true);

      var result2 = a.isBlockChainValid(
          chain: b.blockchain.values.toList(), blockchain: b);

      expect(result2, isNotNull);
      expect(result2, true);
    });
  });
}

//   group('Account', () {
//     // var accountService = AccountService();
//     // test('Found', () {
//     //   final account = accountService.findAccount(
//     //     data: accountService.accountList,
//     //     address: '89sdc89',
//     //   );
//     //   expect(account, isNotNull);
//     // });

//     // test('Find Error ', () {
//     //   expect(
//     //     accountService.findAccount(
//     //       data: accountService.accountList,
//     //       address: '89sdcjj89',
//     //     ),
//     //     null,
//     //   );
//     // });

//     // test('Insufficient funds', () {
//     //   expect(
//     //       accountService.editAccountBalance(
//     //           address: '8nj9ssdcs89', value: 10434.5, transactionType: 0),
//     //       isNull);
//     // });

//     // test('Not Found', () {
//     //   expect(
//     //       accountService.editAccountBalance(
//     //           address: '8scdcs989ff', value: 434.5, transactionType: 1),
//     //       isNull);
//     // });

//     test('Withdraw', () {
//       Iterable l = json.decode(
//         File('accounts.json').readAsStringSync(),
//       );

//       var accounts =
//           List<Account>.from(l.map((model) => Account.fromJson(model)));

//       print(accounts);

//       expect(accountService.withdraw(account: , value: ), 2324);
//     });

//     // test('Deposit', () {
//     //   expect(accountService.withdraw(value, account), 2324);
//     // });
//   });

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
