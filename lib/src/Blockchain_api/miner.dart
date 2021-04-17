import 'package:sketchy_coins/p23_blockchain.dart';
import 'package:sketchy_coins/src/Blockchain_api/blockchainValidation.dart';
import 'package:sketchy_coins/src/Auth_api/EnvValues.dart';
import 'package:sketchy_coins/src/Models/mineResult/mineResult.dart';

class Miner {
  final BlockchainService blockchain;
  var blockChainValidity = BlockChainValidity();

  Miner(this.blockchain);

  Map<String, dynamic> mine({required String recipient,}) {
    if (blockchain.pendingTransactions.isEmpty) {
      return {
        'message': 'Nothing to Mine',
      };
    }

    var lastBlock = blockchain.lastBlock;
    var lastProof = lastBlock.proof;
    var proof = blockchain.proofOfWork(lastProof);
    // Proof found - receive award for finding the proof
    try {
      blockchain.newMineTransaction(
        recipient: recipient,
        amount: enviromentVariables.rewardValue,
      );
    } catch (e) {
      print(e.toString());
      rethrow;
    }

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
