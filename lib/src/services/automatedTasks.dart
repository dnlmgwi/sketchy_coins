import 'dart:async';

import 'package:sketchy_coins/packages.dart';

class AutomatedTasks {
  WalletService walletService;
  MineServices miner;

  AutomatedTasks({required this.miner, required this.walletService});

  Future startAutomatedTasks() async {
    Timer.periodic(Duration(minutes: 1), (timer) async {
      //if both lists are empty fetch more
      try {
        if (walletService.pendingDepositsTansactions.isEmpty) {
          //Get Unclaimed Deposits.
          print('Get Unclaimed Deposits.');
          await _getUnclaimedDeposits().onError((error, stackTrace) =>
              print('Error: $error Stacktrace: $stackTrace'));
        }

        if (walletService.pendingDepositsTansactions.isNotEmpty) {
          // Process The Items and Delete Them from List
          print('Process The Items and Delete Them from List');
          await walletService.initiateTopUp(
            data: walletService.pendingDepositsTansactions,
          );
        }
      } catch (e) {
        print(e); //TODO Notify External Provider
      }
      //Wait for Next Batch.
    });

    Timer.periodic(Duration(minutes: 1), (timer) async {
      try {
        await _processPendingPayments();
      } catch (e) {
        print(e.toString());
      }
    });
  }

  Future<void> _processPendingPayments() async {
    print('payments?');
    if (walletService.pendingTansactions.isEmpty) {
      throw NoPendingTransactionException();
    } else if (walletService.pendingTansactions.isNotEmpty) {
      try {
        await miner.mine();
      } catch (e) {
        rethrow;
      }
    }
  }

  Future<void> _getUnclaimedDeposits() async {
    try {
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
        throw Exception();
      } else {
        if ((response.data as List).isNotEmpty) {
          print('Found something');
          for (var item in response.data as List) {
            await walletService.pendingDepositsTansactions
                .add(RechargeNotification.fromJson(item));
          }
        }
      }
    } catch (e) {
      rethrow;
    }

    print('nothing here ');
  }
}
