import 'dart:convert';
import 'package:sketchy_coins/blockchain.dart';
import 'package:sketchy_coins/src/Account_api/account.dart';
import 'package:sketchy_coins/src/Account_api/accountValidation.dart';
import 'package:sketchy_coins/src/Blockchain_api/miner.dart';
import 'package:sketchy_coins/src/Blockchain_api/blockchainValidation.dart';
import 'package:test/test.dart';

void main() {
  var b = Blockchain();
  var a = BlockChainValidity();
  var miner = Miner(b);
  group('Blockchain', () {
    test('First Test', () {
      expect(b, isNotNull);
      var blockIndex =
          b.newTransaction(sender: 'john', recipient: 'steve', amount: 0.50);

      expect(blockIndex, 1);
      blockIndex =
          b.newTransaction(sender: 'steve', recipient: 'john', amount: 1.50);
      expect(blockIndex, 1);
    });
  });
  group('Block', () {
    test('json encode', () {
      var b = Block(
        index: 0,
        timestamp: 0,
        proof: 0,
        prevHash: '',
        transactions: [],
      );
      var r = json.encode(b);
      expect(r, isNotNull);
    });
  });
  group('Miner', () {
    test('Test', () {
      var result = miner.mine();
      expect(result, isNotNull);
      expect(result.containsKey('prevHash'), isNotNull);
      b.newTransaction(sender: 'steve', recipient: 'john', amount: 1.50);
      var isValid =
          a.isFirstBlockValid(chain: miner.blockchain.getFullChain(), blockchain: b);
      expect(isValid, true);

      var result2 = a.isBlockChainValid(chain: b.getFullChain(), blockchain: b);

      expect(result2, isNotNull);
      expect(result2, true);
    });
  });

  group('Account', () {
    test('Account Validation', () {
      final accountValidity = AccountValidation();
      var accounts = [
        Account(address: '123', balance: 100000, transactions: []),
        Account(address: 'wwwe', balance: 100000, transactions: []),
      ];

      expect(
          accountValidity.findAccount(
            data: accounts,
            address: '123',
          ),
          true);
    });
  });

  group('Blockchain Validation', () {
    test('isFirstBlockValid', () {
      var result = a.isFirstBlockValid(chain: b.getFullChain(), blockchain: b);
      expect(result, isNotNull);
      expect(result, true);
    });

    test('isBlockChainValid', () {
      var result = a.isBlockChainValid(chain: b.getFullChain(), blockchain: b);
      expect(result, isNotNull);
      expect(result, true);
    });

    test('isValidNewBlock', () {
      expect(
          a.isValidNewBlock(
              previousBlock: miner.blockchain.getFullChain().last,
              newBlock: miner.blockchain.getFullChain().first,
              blockchain: b),
          true);
    });
  });
}
