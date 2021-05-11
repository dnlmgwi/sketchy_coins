import 'dart:async';

import 'package:sentry/sentry.dart';
import 'package:sketchy_coins/packages.dart';
import 'package:supabase/supabase.dart';

class AutomatedTasks {
  WalletService walletService;
  MineServices miner;

  AutomatedTasks({
    required this.miner,
    required this.walletService,
  });

  // realtime
  final subscription1 = DatabaseService.sbClient
      .from('beneficiary_accounts')
      .on(SupabaseEventTypes.all, (x) async {
    print('on countries.delete: ${x.table} ${x.eventType} ${x.oldRecord}');
  }).subscribe((String event, {String? errorMsg}) {
    print('event: $event error: $errorMsg');
  });

  //Todo Use Websockets
  Future<void> startAutomatedTasks() async {
    await Future.delayed(Duration(minutes: 10))
        .then((value) => // remember to remove subscription
            DatabaseService.sbClient.removeSubscription(subscription1));
  }

  Future<void> _processPendingPayments() async {
    print('payments?');
    if (walletService.pendingTansactions.isEmpty) {
      throw NoPendingTransactionException();
    } else if (walletService.pendingTansactions.isNotEmpty) {
      try {
        await miner.mine().then((_) => DatabaseService.sbClient);
      } catch (exception, stackTrace) {
        await Sentry.captureException(
          exception,
          stackTrace: stackTrace,
        );
      }
    }
  }

  Future<void> _getUnclaimedDeposits() async {
    try {
      var response = await DatabaseService.client
          .from('recharge_notifications')
          .select()
          .match({
            'claimed': false,
          })
          .execute()
          .onError(
            (exception, stackTrace) async {
              await Sentry.captureException(
                exception,
                stackTrace: stackTrace,
              );
              throw Exception(exception);
            },
          );

      if (response.data == null) {
        DatabaseService.sbClient;
      } else {
        if ((response.data as List).isNotEmpty) {
          print('Found something');
          for (var item in response.data as List) {
            await walletService.pendingDepositsTansactions
                .add(RechargeNotification.fromJson(item));
          }
        }
      }
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
