import 'dart:async';
import 'package:sketchy_coins/packages.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart' as ws;

import 'package:web_socket_channel/web_socket_channel.dart' as wsChannel;

void main(List<String> arguments) async {
  Hive.init('./storage');
  Hive.registerAdapter(TransactionRecordAdapter());
  Hive.registerAdapter(RechargeNotificationAdapter());
  await Hive.openBox<TransactionRecord>('transactions');
  await Hive.openBox<RechargeNotification>('rechargeNotifications');

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

  var miner = MineServices(blockchain: blockchainService);

  Future<void> processPendingPayments() async {
    if (miner.blockchain.pendingTansactions.isNotEmpty) {
      await miner.mine();
    }
  }

  Timer.periodic(Duration(seconds: 5), (timer) async {
    try {
      await processPendingPayments();
    } catch (e) {
      print(e.toString());
    }
  });

  Future getUnclaimedDeposits() async {
    var response = await DatabaseService.client
        .from('rechargeNotifications')
        .select()
        .match({
          'claimed': false,
        })
        .execute()
        .onError(
          (error, stackTrace) => throw Exception(error),
        );

    if (response.data == null) {
      //Stop Checking
    }

    var data = response.data as List;

    for (var item in data) {
      await miner.blockchain.pendingDepositsTansactions
          .add(RechargeNotification.fromJson(item));
    }

    print('process findID');

    //Get Unclaimed Deposits.
    //Add The to List prevent Duplicates.
    //Process The Items and Delete Them from List
    //Wait for Next Batch.
  }

  // Future<void> processMobileMoneyPayments(data) async {}
  // var fetch = true;

  // await blockchainService.recharge(data: data);

  // if (miner.blockchain.pendingDepositsTansactions.isNotEmpty && fetch) {
  //   Timer.periodic(Duration(seconds: 10), (timer) async {
  // var response = await DatabaseService.client
  //     .from('rechargeNotifications')
  //     .select()
  //     .match({
  //       'claimed': false,
  //     })
  //     .lte('timestamp', DateTime.now().millisecondsSinceEpoch)
  //     .execute()
  //     .onError(
  //       (error, stackTrace) => throw Exception(error),
  //     );

  // if (response.data == null) {
  //   fetch = false;
  // }

  // var data = response.data as List;

  // for (var item in data) {
  //   await miner.blockchain.pendingDepositsTansactions
  //       .add(RechargeNotification.fromJson(item));
  // }

  //     print('process findID');
  //   });
  // } else {
  //   await processMobileMoneyPayments(
  //           miner.blockchain.pendingDepositsTansactions)
  //       .whenComplete(() => fetch = true);
  //   print('process Mobi');
  // }

  Timer.periodic(Duration(seconds: 5), (timer) async {
    try {
      await processPendingPayments();
    } catch (e) {
      print(e.toString());
    }
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

  var server = await shelf_io.serve(handler, Env.hostName, int.parse(Env.port));

  print('Serving at http://${server.address.host}:${server.port}');

  server.autoCompress;
}
