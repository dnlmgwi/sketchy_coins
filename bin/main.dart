import 'dart:io';
import 'package:hive/hive.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:sketchy_coins/blockchain.dart';
import 'package:sketchy_coins/src/Account_api/account_api.dart';
import 'package:sketchy_coins/src/Auth_api/EnvValues.dart';
import 'package:sketchy_coins/src/Base_api/base_api.dart';
import 'package:sketchy_coins/src/Models/Account/account.dart';
import 'package:sketchy_coins/src/Models/mineResult/mineResult.dart';
import 'package:sketchy_coins/src/Models/transaction/transaction.dart';

void main(List<String> arguments) async {
  Hive.init('./storage');
  Hive.registerAdapter(BlockAdapter());
  Hive.registerAdapter(MineResultAdapter());
  Hive.registerAdapter(AccountAdapter());
  Hive.registerAdapter(TransactionAdapter());

  await Hive.openBox<Block>('blockchain');
  await Hive.openBox<Account>('accounts');
  await Hive.openBox<Transaction>('transactions');

  var handler = Router();
  var portEnv = Platform.environment['PORT'];
  final _port = portEnv == null ? enviromentVariables.port : int.parse(portEnv);

  var server = await io.serve(
    handler,
    enviromentVariables.hostName,
    _port,
  );

  print('Serving at http://${server.address.host}:${server.port}');

  handler.mount('/v1/info/', BaseApi().router);
  handler.mount('/v1/blockchain/', BlockChainApi().router);
  handler.mount('/v1/account/', AccountApi().router);
}
