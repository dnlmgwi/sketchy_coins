import 'package:sketchy_coins/packages.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

void main(List<String> arguments) async {
  load();
  Hive.init('./storage');

  Hive.registerAdapter(TransactionRecordAdapter());
  Hive.registerAdapter(RechargeNotificationAdapter());
  await Hive.openBox<TransactionRecord>('transactions');
  await Hive.openBox<RechargeNotification>('rechargeNotifications');

  /// Start Redis Token Service
  final tokenService = TokenService();
  await tokenService.start();

  final databaseService = DatabaseService();
  final walletService = WalletService();

  final authService = AuthService(
    databaseService: databaseService,
  );

  final blockchainService = BlockchainService(
    databaseService: databaseService,
    walletService: walletService,
  );

  final miner = MineServices(
    blockchain: blockchainService,
  );

  final automatedTasks = AutomatedTasks(
    miner: miner,
    walletService: walletService,
  );

  await automatedTasks.startAutomatedTasks();

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
    '/v1/auth/',
    AuthApi(
      secret: Env.secret!,
      tokenService: tokenService,
      databaseService: databaseService,
    ).router,
  );

  app.mount(
    '/v1/blockchain/',
    BlockChainApi(
      databaseService: databaseService,
      blockchainService: blockchainService,
      walletService: walletService,
    ).router,
  );

  app.mount(
    '/v1/account/',
    AccountApi(
      authService: authService,
      databaseService: databaseService,
    ).router,
  );

  var server =
      await shelf_io.serve(handler, Env.hostName, int.parse(Env.port!));
  server.autoCompress;
  print('Serving at http://${server.address.host}:${server.port}');
}
