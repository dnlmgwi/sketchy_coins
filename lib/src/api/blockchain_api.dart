import 'package:sketchy_coins/packages.dart';

class BlockChainApi {
  BlockchainService blockchainService;
  DatabaseService databaseService;

  BlockChainApi({
    required this.blockchainService,
    required this.databaseService,
  });

  Handler get router {
    final router = Router();
    final handler = Pipeline().addMiddleware(checkAuth()).addHandler(router);

    final _accountService = AccountService(
      databaseService: databaseService,
    );

    var miner = MineServices(blockchain: blockchainService);
    var blockChainValidity = BlockChainValidationService();

    //TODO: Find Account on tranfer Shouldnt Call Sensitve Data

    router.post(
      '/transfer',
      ((
        Request request,
      ) async {
        try {
          final authDetails = request.context['authDetails'] as JWT;
          final user = await _accountService.findAccount(
            address: authDetails.subject.toString(),
          );
          final payload = await request.readAsString();
          final data = json.decode(payload);

          var recipientAddress = data['recipient'];

          var amount = double.parse(data['amount'].toString());

          if (noSenderCheck(user.address)) {
            return Response.forbidden(
              noSenderError(),
              headers: {
                HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
              },
            );
          }

          if (noRecipientCheck(recipientAddress)) {
            return Response.forbidden(
              noRecipientError(),
              headers: {
                HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
              },
            );
          }

          if (noAmountCheck(amount)) {
            return Response.forbidden(
              noAmountError(),
              headers: {
                HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
              },
            );
          }

          try {
            await blockchainService.initiateTransfer(
              senderAddress: user.address,
              recipientAddress: recipientAddress,
              amount: amount,
            );

            return Response.ok(
              json.encode({
                'data': {
                  'message': 'Transaction Pending',
                  'balance': '${user.balance - amount}',
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

    router.post('/recharge', (Request request) async {
      final authDetails = request.context['authDetails'] as JWT;
      final user = await _accountService.findAccount(
        address: authDetails.subject.toString(),
      );
      final payload = await request.readAsString();
      final userData = json.decode(payload);

      final transID = userData['transID'];
      // final address = userData['address'];
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

      if (user.address.isEmpty || user.address == '') {
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
        rechargeResult = await blockchainService.recharge(
          recipient: user.address,
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

    return handler;
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

  bool noAmountCheck(double data) =>
      data <
      double.parse(
        Env.minTransactionAmount,
      );

  bool noRecipientCheck(String data) => data == '' || data.isEmpty;

  bool noSenderCheck(String data) => data == '' || data.isEmpty;
}
