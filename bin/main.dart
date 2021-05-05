import 'dart:async';

import 'package:sketchy_coins/packages.dart';
import 'package:shelf/shelf_io.dart' as _io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:shelf_hotreload/shelf_hotreload.dart';

void main(List<String> arguments) async {
  Hive.init('./storage');
  Hive.registerAdapter(TransactionRecordAdapter());
  await Hive.openBox<TransactionRecord>('transactions');

  Future<HttpServer> createServer() async {
    final tokenService = TokenService(
      secret: Env.secret,
    );

    final databaseService = DatabaseService();

    final authService = AuthService(databaseService: databaseService);

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

    var miner = MineServices(blockchain: blockchainService);

    var cron = Cron();

    Future<void> processPendingPayments() async {
      if (miner.blockchain.pendingTansactions.isNotEmpty) {
        await miner.mine();
      }
    }

    try {
      cron.schedule(Schedule.parse('*/3 * * * * *'), () async {
        await processPendingPayments();
      });
    } catch (e) {
      print(e);
    }

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
        databaseService: databaseService,
        blockchainService: blockchainService,
      ).router,
    );

    app.mount(
      '/v1/account/',
      AccountApi(
        authService: authService,
        databaseService: databaseService,
      ).router,
    );

    var server = await _io.serve(handler, Env.hostName, int.parse(Env.port));

    print('Serving at ws://${server.address.host}:${server.port}');

    // server.autoCompress;

    return server;
  }

  withHotreload(() => createServer());
}

Future processPendingPayments(MineServices miner) async {
  await miner.mine().onError((error, stackTrace) => print(error.toString()));
}
