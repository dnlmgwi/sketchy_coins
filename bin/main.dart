import 'package:sketchy_coins/packages.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main(List<String> arguments) async {
  Hive.init('./storage');
  Hive.registerAdapter(BlockAdapter());
  Hive.registerAdapter(MineResultAdapter());
  Hive.registerAdapter(AccountAdapter());
  Hive.registerAdapter(TransactionRecordAdapter());
  Hive.registerAdapter(TokenPairAdapter());

  await Hive.openBox<Block>('blockchain');
  await Hive.openBox<Account>('accounts');
  await Hive.openBox<TransactionRecord>('transactions');

  final _accountsDb =
      Hive.box<Account>('accounts'); //TODO: Implement PostgresSQL Database

  final tokenService = TokenService(
    secret: Env.secret,
  );

  await tokenService.start();

  var app = Router();
  var portEnv = Platform.environment['PORT'];
  final _port = portEnv == null ? int.parse(Env.port) : int.parse(portEnv);

  var handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(handleCors())
      .addMiddleware(handleAuth(
        secret: Env.secret,
      ))
      .addHandler(app);

  var server = await io.serve(
    handler,
    Env.hostName,
    _port,
  );

  // webSocketHandler((webSocket) {
  //   webSocket.stream.listen((message) {
  //     webSocket.sink.add('echo $message');
  //   });
  // });

  // await shelf_io.serve(handler, Env.hostName, _port).then((server) {
  //   print('Serving at ws://${server.address.host}:${server.port}');
  // });

  app.mount(
    '/v1/info/',
    BaseApi().router,
  );

  app.mount(
    '/v1/auth/',
    AuthApi(
      store: _accountsDb,
      secret: Env.secret,
      tokenService: tokenService,
    ).router,
  );

  app.mount(
    '/v1/blockchain/',
    BlockChainApi().router,
  );
  app.mount(
    '/v1/account/',
    AccountApi().router,
  );

  print(
    'Serving at http://${server.address.host}:${server.port}',
  );
}
