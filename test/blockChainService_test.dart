import 'package:sketchy_coins/packages.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import 'package:timeago/timeago.dart' as timeago;

void main() async {
  Hive.init('System_test');
  Hive.registerAdapter(TransactionRecordAdapter());
  Hive.registerAdapter(RechargeNotificationAdapter());

  await Hive.openBox<RechargeNotification>('rechargeNotifications');
  await Hive.openBox<TransactionRecord>('transactions');

  final tokenService = TokenService(
    secret: Env.secret,
  );

  await tokenService.start();

  final databaseService = DatabaseService();
  final authService = AuthService(
    databaseService: databaseService,
  );

  final blockchainService = BlockchainService(
    databaseService: databaseService,
  );

  var miner = MineServices(blockchain: blockchainService);

  group('Blockchain Service', () {
    test('Service Active', () {
      expect(blockchainService, isNotNull);
    });
  });

  group('Blockchain Transaction Frequency Limit', () {
    test('Recently transacted', () async {
      var userNow = 1620514690479;

      var recipientAccount = TransAccount(
        status: 'normal',
        phoneNumber: '0997176756',
        id: '3a3cc999-4ac4-400c-b321-fb58b515ce4f',
        balance: 4200.0,
        lastTrans: userNow,
      );

      /// Timeago?
      /// Is Less Then 45min from Now?
      /// How Long Ago?
      /// Is Less then 45min throw Error
      /// Compare Then and Now?
      var now = DateTime.now();
      print(now.millisecondsSinceEpoch);
      var waitingPeriod =
          DateTime.fromMillisecondsSinceEpoch(recipientAccount.lastTrans!)
              .add(const Duration(minutes: 5));
      print('Last Trans: ${recipientAccount.lastTrans}');
      print(
          'Last Trans: ${timeago.format(DateTime.fromMillisecondsSinceEpoch(recipientAccount.lastTrans!))}');
      print(
          'Now: ${timeago.format(DateTime.fromMillisecondsSinceEpoch(userNow))}');

      var timeout = waitingPeriod.compareTo(
          DateTime.fromMillisecondsSinceEpoch(recipientAccount.lastTrans!));

      if (timeout < 0) {
        print('Im Free');
      } else {
        print('Wait My G!');
      }

      // Future recentlyTransacted(TransAccount recipientAccount) async {
      //   var when = DateTime.fromMillisecondsSinceEpoch(
      //     recipientAccount.lastTrans ??
      //         DateTime.now()
      //             .subtract(Duration(minutes: 11))
      //             .millisecondsSinceEpoch,
      //   ).compareTo(DateTime.now().add(
      //     Duration(minutes: 10),
      //   ));
      //   if (when >= 0) {
      //     throw RecentTransException();
      //   }
      // }

      // try {
      //   var response = await recentlyTransacted();
      // expect(await response, isNotNull);
      // } catch (e) {
      //   print(e.toString());
      // }
    });
  });
}
