import 'package:sketchy_coins/blockchain.dart';
import 'package:sketchy_coins/src/mineResult.dart';
import 'package:uuid/uuid.dart';

class Miner {
  final Blockchain blockchain;
  final String nodeId;

  Miner(this.blockchain) : nodeId = Uuid().v4();

  MineResult mine() {
    var lastBlock = blockchain.lastBlock;
    var lastProof = lastBlock.proof;
    var proof = blockchain.proofOfWork(lastProof);
    // Proof found - receive award for finding the proof
    blockchain.newTransaction(sender: '0', recipient: nodeId, amount: 1.0);

    // Forge the new Block by adding it to the chain
    var prevHash = blockchain.hash(lastBlock);
    var block = blockchain.newBlock(
      proof,
      prevHash,
    );
    return MineResult(
        'New Block Forged', block.index, block.transactions, proof, prevHash);
  }
}
