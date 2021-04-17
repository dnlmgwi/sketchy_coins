import 'package:sketchy_coins/packages.dart';
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
  // await Hive.openBox<Transaction>('tokens');

  final _tokenDb =
      Hive.box<Account>('accounts'); //TODO: Implement PostgresSQL Database

  var app = Router();
  var portEnv = Platform.environment['PORT'];
  final _port = portEnv == null ? int.parse(Env.port) : int.parse(portEnv);

  var handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(handleCors())
      .addHandler(app);

  var server = await io.serve(
    handler,
    Env.hostName,
    _port,
  );

  app.mount('/v1/info/', BaseApi().router);
  app.mount('/v1/auth/', AuthApi(store: _tokenDb, secret: 'mysecret').router);
  app.mount('/v1/blockchain/', BlockChainApi().router);
  // app.mount('/v1/account/', AccountApi().router);

  print('Serving at http://${server.address.host}:${server.port}');
}
