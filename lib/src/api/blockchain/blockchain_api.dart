import 'package:sketchy_coins/packages.dart';
import 'package:sketchy_coins/src/models/transferRequest/transferRequest.dart';

class BlockChainApi {
  BlockchainService blockchainService;
  DatabaseService databaseService;
  WalletService walletService;

  BlockChainApi({
    required this.blockchainService,
    required this.databaseService,
    required this.walletService,
  });

  Handler get router {
    final router = Router();
    final handler = Pipeline().addMiddleware(checkAuth()).addHandler(router);

    final _accountService = AccountService(
      databaseService: databaseService,
    );

    var miner = MineServices(blockchain: blockchainService);

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

          var data = TransferRequest.fromJson(
              json.decode(await request.readAsString()));

          BlockChainApiValidation.nullInputValidation(
            recipientid: data.id,
            amount: data.amount,
          );

          if (BlockChainApiValidation.recipientCheck(data.id!) ||
              !isUUID(data.id)) {
            return Response.forbidden(
              BlockChainApiResponses.recipientError(),
              headers: {
                HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
              },
            );
          }

          if (BlockChainApiValidation.amountCheck(data.amount!)) {
            return Response.forbidden(
              BlockChainApiResponses.amountError(),
              headers: {
                HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
              },
            );
          }

          await walletService.initiateTransfer(
            senderid: user.id,
            recipientid: data.id!,
            amount: data.amount!,
          );

          return Response.ok(
            json.encode({
              'data': {
                'message': 'Transaction Pending',
                'balance': '${user.balance - data.amount!}',
                'transaction': data.toJson(),
              }
            }),
            headers: {
              HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
            },
          );
        } on FormatException catch (e) {
          return Response(
            HttpStatus.badRequest,
            body: json.encode({
              'data': {
                'message': 'Provide a valid Request refer to documentation'
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
