import 'package:sketchy_coins/blockchain.dart';
import 'package:sketchy_coins/src/Blockchain_api/blockchainValidation.dart';
import 'package:sketchy_coins/src/Auth_api/EnvValues.dart';
import 'package:sketchy_coins/src/Models/mineResult/mineResult.dart';

class Miner {
  final BlockchainService blockchain;
  var blockChainValidity = BlockChainValidity();

  Miner(this.blockchain);

  Map<String, dynamic> mine({required String address}) {
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
        sender:
            '8e3153aa41771bf79089df1d858a274c9af598656688b188e803249ecb44de7f',
        recipient: address,
        amount: enviromentVariables.rewardValue,
      );
    } catch (e) {
      print(e.toString());
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
