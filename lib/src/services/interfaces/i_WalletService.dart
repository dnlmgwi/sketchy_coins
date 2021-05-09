import 'package:sketchy_coins/packages.dart';

abstract class IWalletService {
  Future<void> processPayments();
  Future<void> depositProcess(TransactionRecord element);
  Future<void> withdrawProcess(TransactionRecord element);
  Future<void> transferProcess(TransactionRecord element);
  Future editAccountBalance({
    required TransAccount senderAccount,
    TransAccount? recipientAccount,
    required double value,
    required int transactionType,
  });

  Future<TransAccount> deposit({
    required double value,
    required TransAccount account,
  });

  Future<void> transfer({
    required double value,
    required TransAccount senderAccount,
    required TransAccount recipientAccount,
  });

  Future<void> withdraw({
    required double value,
    required TransAccount account,
  });

  Future<double> checkAccountBalance({
    required double value,
    required TransAccount account,
  });

  Future initiateTopUp({required Box<RechargeNotification> data});

  double extractAmount(RechargeNotification item);

  Future<void> initiateTransfer({
    required String? senderid,
    required String recipientid,
    required double amount,
  });

  Future addToPendingDeposit(String sender, String recipient, double amount);
  void addToPendingWithDraw(String sender, String recipient, double amount);
  void addToPendingTransfer(String sender, String recipient, double amount);

  Future<bool> accountStatusCheck(String? sender);

  Future<bool> accountPaymentValidation(String sender);

  Future<bool> recipientValidation(
    String recipient,
  );

  Future<void> changeAccountStatusToProcessing(String id);
  Future<void> changeClaimToTrue(String transID);
  Future<void> changeAccountStatusNormal(String? id);
}
