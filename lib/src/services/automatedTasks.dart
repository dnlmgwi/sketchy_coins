import 'dart:async';

import 'package:sentry/sentry.dart';
import 'package:sketchy_coins/packages.dart';
import 'package:supabase/supabase.dart';
import 'package:throttling/throttling.dart';

class AutomatedTasks {
  WalletService walletService;
  MineServices miner;

  AutomatedTasks({
    required this.miner,
    required this.walletService,
  });

  /// Use Websockets Done! Listerning to Internal Stream
  Future<void> startAutomatedTasks() async {
    var transStream = walletService.pendingTransactions.watch();
    var depositStream = walletService.pendingDepositsTansactions.watch();
    transStream.listen((event) async {
      final deb = Debouncing(duration: const Duration(seconds: 30));
      await deb.debounce(() async {
        if (walletService.pendingTransactions.isNotEmpty) {
          await _processPendingPayments();
        }
      });
    });

    depositStream.listen((event) async {
      final deb = Debouncing(duration: const Duration(seconds: 5));
      await deb.debounce(() async {
        if (walletService.pendingDepositsTansactions.isEmpty) {
          await _getUnclaimedDeposits();
        }
      });
    });
  }

  Future<void> _processPendingPayments() async {
    print('payments?');
    try {
      await miner.mine();
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
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
        //TODO Review
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
