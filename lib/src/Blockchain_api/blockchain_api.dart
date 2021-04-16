import 'package:shelf_router/shelf_router.dart';
import 'package:sketchy_coins/src/Account_api/accountExeptions.dart';
import 'package:sketchy_coins/src/Auth_api/EnvValues.dart';
import 'blockchainService.dart';
import 'blockchainValidation.dart';
import 'miner.dart';
import 'dart:convert';
import 'package:shelf/shelf.dart';

class BlockChainApi {
  static final blockchainService = BlockchainService();
  var miner = Miner(blockchainService);
  var blockChainValidity = BlockChainValidity();

  Router get router {
    final router = Router();

    router.post(
      '/transactions/pay',
      ((
        Request request,
      ) async {
        try {
          final payload = await request.readAsString();
          final data = json.decode(payload);

          if (noSenderCheck(data)) {
            return Response.forbidden(
              noSenderError(),
              headers: {
                'Content-Type': 'application/json',
              },
            );
          }

          if (noRecipientCheck(data)) {
            return Response.forbidden(
              noRecipientError(),
              headers: {
                'Content-Type': 'application/json',
              },
            );
          }

          if (noAmountCheck(data)) {
            return Response.forbidden(
              noAmountError(),
              headers: {
                'Content-Type': 'application/json',
              },
            );
          }

          try {
            blockchainService.newTransaction(
              sender: data['sender'],
              recipient: data['recipient'],
              amount: double.parse(data['amount'].toString()),
            );

            return Response.ok(
              json.encode({
                'data': {
                  'message': 'Transaction Complete',
                  'transaction': json.decode(payload),
                }
              }),
              headers: {
                'Content-Type': 'application/json',
              },
            );
          } on PendingTransactionException catch (e) {
            return Response.forbidden(
              (json.encode({
                'data': {'message': '${e.toString()}'}
              })),
              headers: {
                'Content-Type': 'application/json',
              },
            );
          }
        } catch (e) {
          print(e);

          return Response.forbidden(
            json.encode({
              'data': {'message': '${e.toString()}'}
            }),
            headers: {
              'Content-Type': 'application/json',
            },
          );
        }
      }),
    );

    router.post(
      '/mine',
      (Request request) async {
        final payload = await request.readAsString();
        final address = json.decode(payload);

        var mineResult = miner.mine(address: address['address']);

        if (address['address'].isEmpty) {
          return Response.forbidden(
            json.encode(
              {
                'data': {
                  'message': 'Please provide a valid address',
                }
              },
            ),
            headers: {
              'Content-Type': 'application/json',
            },
          );
        } else if (mineResult.isNotEmpty) {
          return Response.ok(
            json.encode({'data': mineResult}),
            headers: {
              'Content-Type': 'application/json',
            },
          );
        } else {
          return Response.forbidden(
            json.encode(
              {
                'data': {
                  'message': 'Invalid Address',
                }
              },
            ),
            headers: {
              'Content-Type': 'application/json',
            },
          );
        }
      },
    );

    router.get(
      '/chain',
      (
        Request request,
      ) async {
        if (blockChainValidity.isBlockChainValid(
            chain: miner.blockchain.blockchainStore,
            blockchain: blockchainService)) {
          return Response.ok(
            miner.blockchain.getBlockchain(),
            headers: {
              'Content-Type': 'application/json',
            },
          );
        } else {
          return Response.notFound(
            'Invalid Blockchain',
            headers: {
              'Content-Type': 'application/json',
            },
          );
        }
      },
    );

    return router;
  }

  String noSenderError() {
    return json.encode({
      'data': {
        'message': 'Please Provide Sender Address',
      }
    });
  }

  String noRecipientError() {
    return json.encode({
      'data': {
        'message': 'Please Provide Recipient Address',
      }
    });
  }

  String noAmountError() {
    return json.encode({
      'data': {
        'message':
            'Please include valid amount Greater Than P${enviromentVariables.minTransactionAmount}',
      }
    });
  }

  bool noAmountCheck(data) =>
      data['amount'] == null ||
      data['amount'] < enviromentVariables.minTransactionAmount;

  bool noRecipientCheck(data) => data['recipient'] == '';

  bool noSenderCheck(data) => data['sender'] == '';
}
