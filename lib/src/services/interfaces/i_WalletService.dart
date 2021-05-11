import 'package:sketchy_coins/packages.dart';

abstract class IWalletService {
  Future<void> processPayments(Block element, String id);
  Future<void> depositProcess(TransactionRecord element);
  Future<void> withdrawProcess(TransactionRecord element);
  Future<void> transferProcess(TransactionRecord element);
  Future editAccountBalance({
    required TransAccount senderAccount,
    TransAccount? recipientAccount,
    required int value,
    required int transactionType,
  });

  Future<TransAccount> deposit({
    required int value,
    required TransAccount account,
  });

  Future<void> transfer({
    required int value,
    required TransAccount senderAccount,
    required TransAccount recipientAccount,
  });

  Future<void> withdraw({
    required int value,
    required TransAccount account,
  });

  Future<void> checkAccountBalance({
    required int value,
    required TransAccount account,
  });

  Future initiateTopUp({required Box<RechargeNotification> data});

  int extractMKAmount(RechargeNotification item);

  Future<void> initiateTransfer({
    required String senderid,
    required String recipientid,
    required int amount,
  });

  Future addToPendingDeposit(String sender, String recipient, int amount);
  void addToPendingWithDraw(String sender, String recipient, int amount);
  void addToPendingTransfer(String sender, String recipient, int amount);

  Future<bool> accountStatusCheck(String sender);

  Future<bool> recipientValidation(String recipient);

  Future<void> changeAccountStatusToProcessing(String id);
  Future<void> changeClaimToTrue(String transID);
  Future<void> changeAccountStatusNormal(String id);
}
