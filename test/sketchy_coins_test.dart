import 'dart:convert';
import 'package:sketchy_coins/blockchain.dart';
import 'package:sketchy_coins/miner.dart';
import 'package:sketchy_coins/src/blockchainValidation.dart';
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
      var isValid = a.isFirstBlockValid(miner.blockchain.chain());
      expect(isValid, true);

      var result2 = a.isBlockChainValid(b.chain());

      expect(result2, isNotNull);
      expect(result2, true);
    });
  });

  group('Blockchain Validation', () {
    test('isFirstBlockValid', () {
      var result = a.isFirstBlockValid(b.chain());
      expect(result, isNotNull);
      expect(result, true);
    });

    test('isBlockChainValid', () {
      var result = a.isBlockChainValid(b.chain());
      expect(result, isNotNull);
      expect(result, true);
    });

    test('isValidNewBlock', () {
      expect(
          a.isValidNewBlock(
              miner.blockchain.chain().last, miner.blockchain.chain().first),
          true);
    });
  });
}
