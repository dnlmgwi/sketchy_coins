import 'package:sketchy_coins/packages.dart';

class BlockChainApi {
  BlockchainService blockchainService;

  BlockChainApi({required this.blockchainService});

  Router get router {
    var miner = MineServices(blockchain: blockchainService);
    var blockChainValidity = BlockChainValidationService();

    final router = Router();

    router.post(
      '/transfer',
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
                HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
              },
            );
          }

          if (noRecipientCheck(data)) {
            return Response.forbidden(
              noRecipientError(),
              headers: {
                HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
              },
            );
          }

          if (noAmountCheck(data)) {
            return Response.forbidden(
              noAmountError(),
              headers: {
                HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
              },
            );
          }

          try {
            await blockchainService.initiateTransfer(
              sender: data['sender'],
              recipient: data['recipient'],
              amount: double.parse(data['amount'].toString()),
            );

            return Response.ok(
              json.encode({
                'data': {
                  'message': 'Transaction Pending',
                  'transaction': json.decode(payload),
                }
              }),
              headers: {
                HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
              },
            );
          } on PendingTransactionException catch (e) {
            return Response.forbidden(
              (json.encode({
                'data': {'message': '${e.toString()}'}
              })),
              headers: {
                HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
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
              HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
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
        MineResult mineResult;

        try {
          mineResult = await miner.mine(recipient: address['address']);
        } catch (e) {
          print(e);
          return Response.forbidden(
            json.encode({
              'data': {'message': '${e.toString()}'}
            }),
            headers: {
              HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
            },
          );
        }
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
              HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
            },
          );
        } else if (mineResult.validBlock!) {
          return Response.ok(
            json.encode({'data': mineResult}),
            headers: {
              HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
            },
          );
        }
      },
    );

    router.post('/recharge', (Request request) async {
      final payload = await request.readAsString();
      final userData = json.decode(payload);

      final transID = userData['transID'];
      final address = userData['address'];
      var rechargeResult;

      var regExpPayload = RegExp(
        r'^[A-Za-z0-9-_=]+\.[A-Za-z0-9-_=]+\.?[A-Za-z0-9-_.+/=]*$',
        caseSensitive: false,
        multiLine: false,
      );

      bool isTransID(String transID) {
        return transID.contains(
          regExpPayload,
        );
      }

      if (transID == null || transID == '' || !isTransID(transID)) {
        //Todo: Input Validation Errors
        return Response(
          HttpStatus.badRequest,
          body: json.encode({
            'data': {'message': 'Please provide a valid TransID'}
          }),
          headers: {
            HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
          },
        );
      }

      if (address == null || address == '') {
        return Response(
          HttpStatus.badRequest,
          body: json.encode({
            'data': {'message': 'Please provide a valid Address'}
          }),
          headers: {
            HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
          },
        );
      }

      try {
        //TODO: Once Clained False
        rechargeResult = await miner.recharge(
          recipient: address,
          transID: transID,
        );
      } catch (e) {
        print(e);
        return Response.ok(
          json.encode({
            'data': {'message': '${e.toString()}'}
          }),
          headers: {
            HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
          },
        );
      }

      return Response.ok(
        json.encode({'data': rechargeResult}),
        headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
        },
      );
    });

    router.get(
      '/pending',
      (Request request) async {
        if (blockChainValidity.isBlockChainValid(
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
            'Please include valid amount Greater Than P${Env.minTransactionAmount}',
      }
    });
  }

  bool noAmountCheck(data) =>
      data['amount'] == null ||
      data['amount'] < double.parse(Env.minTransactionAmount);

  bool noRecipientCheck(data) => data['recipient'] == '';

  bool noSenderCheck(data) => data['sender'] == '';
}
