import 'package:sketchy_coins/p23_blockchain.dart';
import 'package:shelf/shelf_io.dart' as io;

void main(List<String> arguments) async {
  Hive.init('./storage');
  Hive.registerAdapter(BlockAdapter());
  Hive.registerAdapter(MineResultAdapter());
  Hive.registerAdapter(AccountAdapter());
  Hive.registerAdapter(TransactionAdapter());

  await Hive.openBox<Block>('blockchain');
  await Hive.openBox<Account>('accounts');
  await Hive.openBox<Transaction>('transactions');

  var app = Router();
  var portEnv = Platform.environment['PORT'];
  final _port = portEnv == null ? enviromentVariables.port : int.parse(portEnv);

  
  var handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(handleCors())
      .addHandler(app);

  var server = await io.serve(
    handler,
    enviromentVariables.hostName,
    _port,
  );

  app.mount('/v1/info/', BaseApi().router);
  app.mount('/v1/blockchain/', BlockChainApi().router);
  app.mount('/v1/account/', AccountApi().router);

  print('Serving at http://${server.address.host}:${server.port}');
}
