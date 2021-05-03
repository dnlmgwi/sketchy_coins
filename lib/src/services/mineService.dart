import 'package:sketchy_coins/packages.dart';

class MineServices {
  BlockchainService blockchain;
  var blockChainValidity = BlockChainValidationService();

  MineServices({required this.blockchain});

  Future<MineResult> mine({
    required String recipient,
  }) async {
    if (blockchain.pendingTransactions.isEmpty) {
      throw Exception('Nothing to Mine');
    }

    var lastBlock = await blockchain.lastBlock;
    var lastProof = lastBlock.proof;
    var proof = blockchain.proofOfWork(lastProof);
    // TODO: Proof found - receive award for finding the proof
    // try {
    //   await blockchain.newMineTransaction(
    //     recipient: recipient,
    //     amount: double.parse(Env.rewardValue),
    //   );
    // } catch (e) {
    //   print(e.toString());
    //   rethrow;
    // }

    // Forge the new Block by adding it to the chain
    var prevHash = blockchain.hash(lastBlock);
    var block = await blockchain.newBlock(
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
      blockIndex: block.index! - 1,
      transactions: block.transactions,
      proof: proof,
      prevHash: prevHash,
    );
  }

  Future recharge({
    required String recipient,
    required String transID,
  }) async {
    var response;
    try {
      response = await blockchain.rechargeAccount(
        recipient: recipient,
        transID: transID,
      );
    } catch (e) {
      print(e.toString());
      rethrow;
    }
    return response;
  }
}
