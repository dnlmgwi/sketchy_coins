import 'package:sketchy_coins/packages.dart';

abstract class IAccountService {
  Future<TransAccount> findAccountDetails({required String id});

  Future<TransAccount> findRecipientDepositAccount(
      {required String phoneNumber});

  // Future<void> deleteAccount() {}
  // Future<void> changePin() {}
}
