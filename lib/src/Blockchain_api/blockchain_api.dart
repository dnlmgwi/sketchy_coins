import 'package:shelf_router/shelf_router.dart';
import 'package:sketchy_coins/src/Models/newTransaction/transactionPost.dart';
import 'blockchain.dart';
import 'blockchainValidation.dart';
import 'miner.dart';
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:sketchy_coins/src/Blockchain_api/kkoin.dart';

class BlockChainApi {
  static final blockchain = Blockchain();
  var miner = Miner(blockchain);
  var blockChainValidity = BlockChainValidity();

  Router get router {
    final router = Router();

    router.post(
      '/transactions/pay',
      ((
        Request request, {
        String? sender,
        String? recipient,
        String? amount,
      }) async {
        //if emptry payload
        final payload = await request.readAsString();
        try {
          final data = TransactionPost.fromJson(json.decode(payload));

          if (data.sender == '') {
            return Response.forbidden(
              json.encode({
                'data': {
                  'message': 'Please Provide Sender Address',
                }
              }),
              headers: {
                'Content-Type': 'application/json',
              },
            );
          }

          if (data.recipient == '') {
            return Response.forbidden(
              json.encode({
                'data': {
                  'message': 'Please Provide Recipient Address',
                }
              }),
              headers: {
                'Content-Type': 'application/json',
              },
            );
          }

          if (data.amount.isNegative || data.amount < kKoin.minAmount) {
            return Response.forbidden(
              json.encode({
                'data': {
                  'message': 'Please include valid amount Greater Than KK10.00',
                }
              }),
              headers: {
                'Content-Type': 'application/json',
              },
            );
          }

          blockchain.newTransaction(
            sender: data.sender,
            recipient: data.recipient,
            amount: double.parse(data.amount.toString()),
          );

          return Response.ok(
            //TODO: Process Payments and Responed
            json.encode({
              'data': {
                'message': 'Transaction Complete',
                'balance': 8.22,
                'transaction': json.decode(payload),
              }
            }),
            headers: {
              'Content-Type': 'application/json',
            },
          );
        } catch (e) {
          return Response.forbidden(json.encode({
            'data': {
              'message': 'No Data Recieved',
            }
          }));
        }
      }),
    );

    router.get(
      '/mine/<address|.*>',
      (Request request, String address) async {
        var mineResult = miner.mine(address: address);

        //Does user exist?
        //Award User with KKoin

        if (address == '223') {
          return Response.ok(
            json.encode({'data': mineResult}),
            headers: {
              'Content-Type': 'application/json',
            },
          );
        } else if (address.isEmpty) {
          return Response.forbidden(
            json.encode(
              {
                'data': {
                  'message': 'Please provide a valid token',
                }
              },
            ),
            headers: {
              'Content-Type': 'application/json',
            },
          );
        } else {
          return Response.forbidden(
            json.encode(
              {
                'data': {
                  'message': 'Invalid Token',
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
          chain: miner.blockchain.getFullChain(),
          blockchain: blockchain,
        )) {
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
}
