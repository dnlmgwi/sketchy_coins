import 'dart:async';

import 'package:sketchy_coins/packages.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

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

  var miner = MineServices(blockchain: blockchainService);

  Future<void> processPendingPayments() async {
    print('payments?');
    if (miner.blockchain.pendingTansactions.isNotEmpty) {
      await miner.mine();
    }
  }

  Future<void> getUnclaimedDeposits() async {
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

    if ((response.data as List).isNotEmpty) {
      print('Found something');
      for (var item in response.data as List) {
        await miner.blockchain.pendingDepositsTansactions
            .add(RechargeNotification.fromJson(item));
      }
    }

    print('nothing here ');
  }

  final cron = Cron();

  var cronDepositString = '*/6 * * * * *';
  var cronPaymentString = '*/6 * * * * *';

  cron.schedule(Schedule.parse(cronDepositString), () async {
    //if both lists are empty fetch more
    if (miner.blockchain.pendingDepositsTansactions.isEmpty) {
      //Get Unclaimed Deposits.
      print('Get Unclaimed Deposits.');
      await getUnclaimedDeposits();
    }

    if (miner.blockchain.pendingDepositsTansactions.isNotEmpty) {
      // Process The Items and Delete Them from List
      print('Process The Items and Delete Them from List');
      await blockchainService.initiateRecharge(
        data: miner.blockchain.pendingDepositsTansactions,
      );
    }
    //Wait for Next Batch.
  });

  cron.schedule(Schedule.parse(cronPaymentString), () async {
    try {
      await processPendingPayments();
    } catch (e) {
      print(e.toString());
    }
  });

  await tokenService.start();

  var app = Router();

  var handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(handleCors())
      .addMiddleware(handleAuth(
        secret: Env.secret,
      ))
      .addHandler(app);

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
