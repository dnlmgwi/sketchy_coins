import 'package:sketchy_coins/blockchain.dart';
import 'package:sketchy_coins/src/Blockchain_api/blockchainValidation.dart';
import 'package:sketchy_coins/src/Blockchain_api/kkoin.dart';
import 'package:sketchy_coins/src/Blockchain_api/mineResult/mineResult.dart';

class Miner {
  final Blockchain blockchain;
  var blockChainValidity = BlockChainValidity();

  Miner(this.blockchain);

  Map<String, dynamic> mine({String? token}) {
    if (blockchain.pendingTransactions.isEmpty) {
      return {
        'message': 'Nothing to Mine',
      };
    }

    var lastBlock = blockchain.lastBlock;
    var lastProof = lastBlock.proof;
    var proof = blockchain.proofOfWork(lastProof);
    // Proof found - receive award for finding the proof
    blockchain.newTransaction(
      sender: '0',
      recipient: token,
      amount: kKoin.reward,
    );

    // Forge the new Block by adding it to the chain
    var prevHash = blockchain.hash(lastBlock);
    var block = blockchain.newBlock(
      proof,
      prevHash,
    );

    var validblock = blockChainValidity.isValidNewBlock(
      blockchain: blockchain,
      newBlock: block,
      previousBlock: lastBlock,
    );

    return MineResult(
      message: 'New Block Forged',
      validBlock: validblock,
      blockIndex: block.index,
      transactions: block.transactions,
      proof: proof,
      prevHash: prevHash,
    ).toJson();
  }
}
