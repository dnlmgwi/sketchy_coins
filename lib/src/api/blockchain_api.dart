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

    router.post(
      '/transfer',
      ((
        Request request,
      ) async {
        try {
          final authDetails = request.context['authDetails'] as JWT;
          final user = await _accountService.findAccountDetails(
            id: authDetails.subject.toString(),
          );
          final payload = await request.readAsString();
          final data = json.decode(payload);

          var recipientid = data['id'];
          var amount = data['amount'];

          if (recipientid == null) {
            //If Body Doesn't container id key
            throw InvalidUserIDException();
          } else if (amount == null) {
            throw InvalidAmountException();
          } else {
            if (noRecipientCheck(recipientid) || !isUUID(recipientid)) {
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
          }

          await blockchainService.initiateTransfer(
            senderid: user.id,
            recipientid: recipientid,
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
        } catch (e) {
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
        'message': 'Please Provide Sender id',
      }
    });
  }

  String noRecipientError() {
    return json.encode({
      'data': {
        'message': 'Please Provide Recipient id',
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

  bool noSenderCheck(String? data) => data == '' || data!.isEmpty;
}
