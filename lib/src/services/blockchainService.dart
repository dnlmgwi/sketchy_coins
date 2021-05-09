import 'package:crypto/crypto.dart' as crypto;
import 'package:sketchy_coins/packages.dart';
import 'package:sketchy_coins/src/services/walletServices.dart';

class BlockchainService {
  DatabaseService databaseService;
  WalletService walletService;

  BlockchainService({
    required this.databaseService,
    required this.walletService,
  });

  Future<Block> newBlock(int proof, String previousHash) async {
    var prevBlock;
    if (previousHash.isEmpty) {
      hash(Block.fromJson(prevBlock.data));
    }

    try {
      prevBlock = await DatabaseService.client
          .from('blockchain')
          .select()
          .limit(1)
          .order('timestamp', ascending: false)
          .execute();

      var currentTransactions =
          walletService.pendingTansactions.values.toList();

      await walletService
          .processPayments()
          .onError((error, stackTrace) =>
              throw Exception(' Error: $error StackTrace: $stackTrace'))
          .then(
            (_) => DatabaseService.client
                .from('blockchain')
                .insert(
                  [
                    Block(
                      index: Block.fromJson(prevBlock.data[0]).index! + 1,
                      timestamp: DateTime.now().millisecondsSinceEpoch,
                      proof: proof,
                      prevHash: previousHash,
                      transactions: List.from(
                        currentTransactions,
                      ),
                    ).toJson()
                  ],
                )
                .execute()
                .then((_) => currentTransactions.clear()),
          )
          .onError(
            (error, stackTrace) =>
                throw Exception(' Error: $error StackTrace: $stackTrace'),
          );
      //Successfully Mined

      if (prevBlock.error != null) {
        throw prevBlock.error!.message;
      }

      var latestBlock = await DatabaseService.client
          .from('blockchain')
          .select()
          .limit(1)
          .order('timestamp', ascending: false)
          .execute(); //TODO on Error Handle Exceptions

      return Block.fromJson(latestBlock.data[0]);
    } on PostgrestError catch (e) {
      print('PostgrestError ${e.code} ${e.message}');
      rethrow;
    }
  }

  Future<Block> get lastBlock async {
    var response;
    try {
      response = await DatabaseService.client
          .from('blockchain')
          .select()
          .limit(1)
          .order('timestamp', ascending: false)
          .execute();
    } catch (e, trace) {
      print('lastBlock ${e.toString()} ${trace.toString()}');
      rethrow;
    }
    ;
    return Block.fromJson(response.data[0]);
  }

  List<TransactionRecord> get pendingTransactions {
    return walletService.pendingTansactions.values.toList();
  }

  String hash(Block block) {
    var blockStr = json.encode(block.toJson());
    var bytes = utf8.encode(blockStr);
    var converted = crypto.sha256.convert(bytes).bytes;
    return HEX.encode(converted);
  }

  int proofOfWork(int? lastProof) {
    var proof = 0;
    while (!validProof(lastProof, proof)) {
      proof++;
    }
    return proof;
  }

  bool validProof(int? lastProof, int proof) {
    var guess = utf8.encode('$lastProof$proof');
    var guessHash = crypto.sha256.convert(guess).bytes;
    return HEX.encode(guessHash).substring(0, 4) == Env.difficulty;
  }

  Future<List<Block>> getBlockchain() async {
    //Todo Handling
    var jsonChain = <Block>[];
    var response = await DatabaseService.client
        .from('blockchain')
        .select()
        // .limit(1) //TODO Get The Whole Blockchain
        .order('index', ascending: true)
        .execute();

    var chain = response.data as List;
    chain.forEach((element) {
      jsonChain.add(Block.fromJson(element));
    });

    return jsonChain;
  }

  String getPendingTransactions() {
    var jsonChain = [];
    walletService.pendingTansactions.values.forEach((element) {
      jsonChain.add(element.toJson());
    });
    json.encode(jsonChain);
    return jsonChain.toString();
  }
}
