import 'package:sketchy_coins/packages.dart';

class BlockChainApi {
  BlockchainService blockchainService;

  BlockChainApi({
    required this.blockchainService,
  });

  Handler get router {
    final router = Router();
    final handler = Pipeline().addMiddleware(checkAuth()).addHandler(router);

    var miner = MineServices(blockchain: blockchainService);

    router.get(
      '/pending',
      (Request request) async {
        if (BlockChainValidationService.isBlockChainValid(
            chain: await miner.blockchain.getBlockchain(),
            blockchain: blockchainService)) {
          return Response.ok(
            miner.blockchain.getPendingTransactions(),
            headers: {
              HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
            },
          );
        } else {
          return Response.notFound(
            'Invalid Blockchain',
            headers: {
              HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
            },
          );
        }
      },
    );

    return handler;
  }
}
