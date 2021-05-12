import 'package:pedantic/pedantic.dart';
import 'package:sketchy_coins/packages.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:sketchy_coins/src/api/stats/stats_api.dart';
import 'package:sketchy_coins/src/services/statisticsService/statisticsService.dart';
import 'package:sentry/sentry.dart';

void main(List<String> arguments) async {
  ///Env
  load();
  await Sentry.init(
    (options) {
      options.dsn = Env.sentry;
    },
    appRunner: initApp, // Init your App.
  );
}

void initApp() async {
  ///Hive
  Hive.init('./storage');
  Hive.registerAdapter(TransactionRecordAdapter());
  Hive.registerAdapter(RechargeNotificationAdapter());
  await Hive.openBox<TransactionRecord>('transactions');
  await Hive.openBox<RechargeNotification>('rechargeNotifications');
  // var offlineScans = await HiveCrdt.open('./offlineScans', Env.systemAddress!);
  // var offlineTransactions =
  //     await HiveCrdt.open('./offlineTransactions', Env.systemAddress!);

  /// Start Redis Token Service
  final tokenService = TokenService();
  await tokenService.start();

  final accountService = AccountService();

  final walletService = WalletService(accountService: accountService);

  final authService = AuthService();

  final blockchainService = BlockchainService(
    walletService: walletService,
  );

  final miner = MineServices(
    blockchain: blockchainService,
  );

  final automatedTasks = AutomatedTasks(
    miner: miner,
    walletService: walletService,
  );
  final statsService = StatisticsService();
  //Automated Tasks
  unawaited(automatedTasks.startAutomatedTasks());

  /// Shelf Router
  var app = Router();

  var handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(handleCors())
      .addMiddleware(handleAuth(
        secret: Env.secret!,
      ))
      .addHandler(app);

  app.mount(
    '/v1/info/',
    StatusApi().router,
  );

  app.mount(
    '/v1/stats/',
    StatsApi(statsService: statsService).router,
  );

  // app.mount(
  //   '/v1/sync/',
  //   OfflineSyncApi(
  //     offlineScans: offlineScans,
  //     offlineTransactions: offlineTransactions,
  //   ).router,
  // );

  app.mount(
    '/v1/auth/',
    AuthApi(
      secret: Env.secret!,
      tokenService: tokenService,
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
      authService: authService,
      walletService: walletService,
    ).router,
  );

  var portEnv = Platform.environment['PORT'];
  var port = portEnv == null ? 9999 : int.parse(portEnv);

  var server = await shelf_io.serve(handler, '0.0.0.0', port);
  server.autoCompress;
  print('Serving at http://${server.address.host}:${server.port}');
}
