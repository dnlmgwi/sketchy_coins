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

    router.post(
      '/transactions/create/<sender>/<recipient>/<amount|[0-9]+>',
      ((
        Request request, {
        String sender,
        String recipient,
        String amount,
      }) {
        sender = params(request, 'sender');
        recipient = params(request, 'recipient');
        amount = params(request, 'amount');
        final parsedAmount = double.tryParse(amount);

        blockchain.newTransaction(
          sender: sender,
          recipient: recipient,
          amount: parsedAmount,
        );

        return Response.ok(
          'Transaction Complete',
          headers: {
            'Content-Type': 'application/json',
          },
        );
      }),
    );

    router.get('/mine', (Request request) async {
      var mineResult = miner.mine();
      return Response.ok(
        json.encode(mineResult),
        headers: {
          'Content-Type': 'application/json',
        },
      );
    });

    router.get('/chain', (Request request) async {
      return Response.ok(
        miner.blockchain.getBlockchain(),
        headers: {
          'Content-Type': 'application/json',
        },
      );
    });
    return router;
  }
}
