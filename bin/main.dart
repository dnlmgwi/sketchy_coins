import 'dart:convert';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:sketchy_coins/blockchain.dart';
import 'package:sketchy_coins/src/Blockchain_api/blockchain_api.dart';
import 'package:sketchy_coins/src/Models/Account/account.dart';
import 'package:sketchy_coins/src/Models/mineResult/mineResult.dart';
import 'package:sketchy_coins/src/Models/transaction/transaction.dart';

void main(List<String> arguments) async {
  Hive.init('kkoin');
  Hive.registerAdapter(BlockAdapter());
  Hive.registerAdapter(MineResultAdapter());
  Hive.registerAdapter(TransactionAdapter());

  await Hive.openBox<Block>('blockchain');
  await Hive.openBox<Account>('accounts');
  await Hive.openBox<Transaction>('transactions');

  var handler = Router();

  var portEnv = Platform.environment['PORT'];

  final _hostName = 'localhost';
  final _port = portEnv == null ? 8080 : int.parse(portEnv);
  ;
  var server = await io.serve(handler, _hostName, _port);
  print('Serving at http://${server.address.host}:${server.port}');

  handler.get('/', (Request request) {
    final data = {
      'message': 'Welcome to the KKoin.',
      'status': 'Testing',
      'version': '0.0.0-alpha',
      'activeEndpoints': [
        'http://$_hostName:$_port/v1/blockchain/chain',
        'http://$_hostName:$_port/v1/blockchain/transactions/create',
        'http://$_hostName:$_port/v1/blockchain/mine'
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
  // app.mount('/v1/account/', AccountApi().router);
}
