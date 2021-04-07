import 'package:sketchy_coins/blockchain.dart';
import 'package:sketchy_coins/miner.dart';

void main(List<String> arguments) {
  var blockchain = Blockchain();
  var miner = Miner(blockchain);

  blockchain.newTransaction(
      sender: 'Daniel', recipient: 'Jvvames', amount: 100);
  blockchain.newTransaction(
      sender: 'Daniels', recipient: 'Jamdttes', amount: 1000);
  blockchain.newTransaction(
      sender: 'Danielyyss', recipient: 'Jam767es', amount: 15000);

  blockchain.newTransaction(
      sender: 'Daniel76ss', recipient: 'Jamfhes', amount: 10600);
  blockchain.newTransaction(
      sender: 'Danieluju76ss', recipient: 'Jamyjtufhes', amount: 1002560);
  print('before mine ${miner.blockchain.chain().last.toJson()}');
  miner.mine();
  print('After mine 1 ${miner.blockchain.chain().last.toJson()}');
  blockchain.newTransaction(
      sender: 'Daniel', recipient: 'Jvvames', amount: 100);
  blockchain.newTransaction(
      sender: 'Daniels', recipient: 'Jamdttes', amount: 1000);
  blockchain.newTransaction(
      sender: 'Danielyyss', recipient: 'Jam767es', amount: 15000);

  blockchain.newTransaction(
      sender: 'Daniel76ss', recipient: 'Jamfhes', amount: 10600);
  blockchain.newTransaction(
      sender: 'Danieluju76ss', recipient: 'Jamyjtufhes', amount: 1002560);
  print('Before mine 2 ${miner.blockchain.chain().last.toJson()}');

  blockchain.newTransaction(
      sender: 'Daniel76ss', recipient: 'Jamfhes', amount: 10600);

  blockchain.newTransaction(
      sender: 'Danieluju76ss', recipient: 'Jamyjtufhes', amount: 1002560);
  print(miner.blockchain.chain().last.toJson());

  var result = miner.mine();
  print(result.message);
  result.transactions.forEach((element) {
    print('Mined Data ${element.toJson()}');
  });
  print('After mine 2 ${miner.blockchain.chain().last.toJson()}');
  print('Full chain: ${blockchain.getJsonChain()}');
}
