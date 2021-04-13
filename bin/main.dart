import 'dart:convert';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:sketchy_coins/blockchain.dart';
import 'package:sketchy_coins/src/Account_api/account_api.dart';
import 'package:sketchy_coins/src/Blockchain_api/blockchain_api.dart';
import 'package:sketchy_coins/src/Models/Account/account.dart';
import 'package:sketchy_coins/src/Models/mineResult/mineResult.dart';
import 'package:sketchy_coins/src/Models/transaction/transaction.dart';

void main(List<String> arguments) async {
  Hive.init('kkoin');
  Hive.registerAdapter(BlockAdapter());
  Hive.registerAdapter(MineResultAdapter());
  Hive.registerAdapter(AccountAdapter());
  Hive.registerAdapter(TransactionAdapter());

  await Hive.openBox<Block>('blockchain');
  await Hive.openBox<Account>('accounts');
  await Hive.openBox<Transaction>('transactions');

  var handler = Router();

  var portEnv = Platform.environment['PORT'];

  final _hostName = '0.0.0.0';
  final _port = portEnv == null ? 9999 : int.parse(portEnv);
  ;
  var server = await io.serve(handler, _hostName, _port);
  print('Serving at http://${server.address.host}:${server.port}');

  handler.get('/', (Request request) {
    final data = {
      'message': 'Welcome to the KKoin.',
      'status': 'Testing',
      'version': '0.0.3-alpha',
      'activeEndpoints': [
        '/v1/blockchain/chain',
        '/v1/blockchain/transactions/create',
        '/v1/blockchain/mine',
        '/v1/account/create',
        '/v1/account/accounts'
      ]
    };
    return Response.ok(
      json.encode(data),
      headers: {
        'Content-Type': 'application/json',
      },
    );
  });

  //v1 of KKoin Api
  handler.mount('/v1/blockchain/', BlockChainApi().router);
  handler.mount('/v1/account/', AccountApi().router);
}
