import 'package:sketchy_coins/packages.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';

void main(List<String> arguments) async {
  Hive.init('./storage');
  Hive.registerAdapter(TransactionRecordAdapter());

  await Hive.openBox<TransactionRecord>('transactions');

  final tokenService = TokenService(
    secret: Env.secret,
  );

  final databaseService = DatabaseService();

  final blockchainService = BlockchainService(
    databaseService: databaseService,
  );

  await tokenService.start();

  var app = Router();

  var handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(handleCors())
      .addMiddleware(handleAuth(
        secret: Env.secret,
      ))
      .addHandler(app);

  webSocketHandler((webSocket) {
    webSocket.stream.listen((message) {
      webSocket.sink.add('echo $message');
    });
  });

  await shelf_io
      .serve(handler, Env.hostName, int.parse(Env.port))
      .then((server) {
    print('Serving at ws://${server.address.host}:${server.port}');
  });

  app.mount(
    '/v1/info/',
    BaseApi().router,
  );

  app.mount(
    '/v1/auth/',
    AuthApi(
      secret: Env.secret,
      tokenService: tokenService,
      databaseService: databaseService,
    ).router,
  );

  app.mount(
    '/v1/blockchain/',
    BlockChainApi(
      blockchainService: blockchainService,
    ).router,
  );

  app.mount(
    '/v1/account/',
    AccountApi(
      databaseService: databaseService,
    ).router,
  );
}
