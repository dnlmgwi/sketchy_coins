import 'package:shelf_router/shelf_router.dart';
import 'package:sketchy_coins/blockchain.dart';
import 'package:sketchy_coins/miner.dart';
import 'dart:convert';

import 'package:shelf/shelf.dart';

class BlockChainApi {
  static final blockchain = Blockchain();
  var miner = Miner(blockchain);

  Router get router {
    final router = Router();
    router.post('/transactions/create', (Request request) async {
      var payload = await request.readAsString();

      blockchain.newTransaction(
        amount: 2.0,
        recipient: '949',
        sender: '0',
      );

      payload = blockchain.getJsonChain();

      return Response.ok(
        payload,
        headers: {
          'Content-Type': 'application/json',
        },
      );
    });

    router.get('/mine', (Request request) async {
      var mineResult = miner.mine();
      return Response.ok(
        json.encode(mineResult.toJson()),
        headers: {
          'Content-Type': 'application/json',
        },
      );
    });

    router.get('/chain', (Request request) async {
      var payload = miner.blockchain.getJsonChain();
      return Response.ok(
        payload,
        headers: {
          'Content-Type': 'application/json',
        },
      );
    });
    return router;
  }
}
