import 'package:sentry/sentry.dart';
import 'package:sketchy_coins/packages.dart';

class AccountService {
  Future<TransAccount> findAccountDetails({required String id}) async {
    var response;
    try {
      response = await DatabaseService.client
          .from('beneficiary_accounts')
          .select(
            'status, balance, id, phone_number, last_trans',
          )
          .match({
        'id': id,
      }).execute();
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      throw Exception(exception);
    }

    var result = response.data as List;

    if (result.isEmpty) {
      throw AccountNotFoundException();
    }

    return TransAccount.fromJson(response.data[0]);
  }

  Future<TransAccount> findRecipientDepositAccount(
      {required String phoneNumber}) async {
    var response;
    try {
      response = await DatabaseService.client
          .from('beneficiary_accounts')
          .select(
            'status, balance, id, phone_number, last_trans',
          )
          .match({
        'phoneNumber': phoneNumber,
      }).execute();
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
    }

    var result = response.data as List;

    if (result.isEmpty) {
      throw AccountNotFoundException();
    }

    return TransAccount.fromJson(response.data[0]);
  }
}
