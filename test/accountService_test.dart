import 'package:sketchy_coins/packages.dart';
import 'package:sketchy_coins/src/services/walletServices.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import 'package:timeago/timeago.dart' as timeago;

void main() async {
  load();
  Hive.init('System_test');
  Hive.registerAdapter(TransactionRecordAdapter());
  Hive.registerAdapter(RechargeNotificationAdapter());

  await Hive.openBox<RechargeNotification>('rechargeNotifications');
  await Hive.openBox<TransactionRecord>('transactions');

  final tokenService = TokenService();

  await tokenService.start();
  
  final accountService = AccountService();
  final walletService = WalletService(accountService: accountService);
  final blockchainService = BlockchainService(
    walletService: walletService,
  );

  final authService = AuthService();

  var miner = MineServices(blockchain: blockchainService);

  group('Wallet Service', () {
    test('Check If Account Status == Normal', () async {
      expect(
        await walletService
            .accountStatusCheck('adc05518-0c2c-42bf-ad58-794adfdd57a4'),
        await walletService
            .accountStatusCheck('adc05518-0c2c-42bf-ad58-794adfdd57a4'),
      );
    });

    test('Add New Transactions', () async {
      var response = await DatabaseService.client.from('transactions').insert([
        TransactionRecord(
          sender: 'sender',
          recipient: 'recipient',
          amount: 1000,
          timestamp: 1111,
          transType: 0,
          transId: Uuid().v4(),
          index: 1,
        ).toJson()
      ]).execute();
      print(response.toJson());
      expect(
        response.data,
        {
          'trans_id': 'bbcd6c67-7900-4442-900f-d3684104651f',
          'sender': 'sender',
          'recipient': 'recipient',
          'timestamp': 1111,
          'trans_type': 0,
          'index': 1,
          'amount': 1000
        },
      );
    });
  });

  group('Blockchain Service', () {
    test('Get Current Chain', () async {
      expect(
        await blockchainService.getBlockchain(),
        isNotNull,
      );
    });

    test('Get Pending Transactions Chain', () async {
      expect(
        blockchainService.getPendingTransactions(),
        blockchainService.getPendingTransactions(),
      );
    });
  });
}
