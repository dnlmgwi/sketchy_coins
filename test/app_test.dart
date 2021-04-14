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
          sender:
              'a23f0faec57e4219d83c4b67b5cea0f185718dbd4a1eb6d744e1e1bc69fd8a4e',
          recipient:
              'd421137d32509aec97b1505027b45499f320f57a812afa9b9fae61f073d64c7d',
          amount: 1000);

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
        accountService.createAccount(pin: '9', number: '0');
        expect(accountService.accountList.values, isNotNull);
      },
    );

    test('List Accounts', () {
      expect(accountService.accountList.values, isNotNull);
      accountService.accountList.values
          .forEach((element) => print(element.toJson()));
    });

    test(
      'Find Account',
      () {
        var account = accountService.findAccount(
            accounts: accountService.accountList,
            address:
                'a23f0faec57e4219d83c4b67b5cea0f185718dbd4a1eb6d744e1e1bc69fd8a4e');
        expect(account.toJson(), {
          'address':
              'a23f0faec57e4219d83c4b67b5cea0f185718dbd4a1eb6d744e1e1bc69fd8a4e',
          'status': 'normal',
          'balance': 10000.0
        });
      },
    );

    test(
      'Account Not Found',
      () {
        try {
          var account = accountService.findAccount(
              accounts: accountService.accountList,
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
            'Before: ${accountService.findAccount(accounts: accountService.accountList, address: 'd421137d32509aec97b1505027b45499f320f57a812afa9b9fae61f073d64c7d').toJson()}');
        expect(
            account = accountService.deposit(
                account: accountService.findAccount(
                    accounts: accountService.accountList,
                    address:
                        'a23f0faec57e4219d83c4b67b5cea0f185718dbd4a1eb6d744e1e1bc69fd8a4e'),
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
                      accounts: accountService.accountList,
                      address:
                          'a23f0faec57e4219d83c4b67b5cea0f185718dbd4a1eb6d744e1e1bc69fd8a4e'),
                  value: 0.3),
              accountService
                  .findAccount(
                      accounts: accountService.accountList,
                      address:
                          'a23f0faec57e4219d83c4b67b5cea0f185718dbd4a1eb6d744e1e1bc69fd8a4e')
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
                  accounts: accountService.accountList,
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
                      accounts: accountService.accountList,
                      address:
                          'd421137d32509aec97b1505027b45499f320f57a812afa9b9fae61f073d64c7d'),
                  value: 19),
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
                    accounts: accountService.accountList,
                    address:
                        'd421137d32509aec97b1505027b45499f320f57a812afa9b9fae61f073d64c7d'),
                value: 100),
            account);

        print('After: $account');
      },
    );
  });
  group('Miner', () {
    test('Test', () {
      var result = miner.mine(
          address:
              'd421137d32509aec97b1505027b45499f320f57a812afa9b9fae61f073d64c7d');
      expect(result, isNotNull);
      expect(result.containsKey('prevHash'), isNotNull);
      blockchainService.newTransaction(
          sender:
              'd421137d32509aec97b1505027b45499f320f57a812afa9b9fae61f073d64c7d',
          recipient:
              'd421137d32509aec97b1505027b45499f320f57a812afa9b9fae61f073d64c7d',
          amount: 19);
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
