import 'package:sentry/sentry.dart';
import 'package:sketchy_coins/packages.dart';

class AuthValidationService {
  static Future<Account> findAccount({required String id}) async {
    var response = await DatabaseService.client
        .from('beneficiary_accounts')
        .select()
        .match({
          'id': id,
        })
        .execute()
        .onError(
          (error, stackTrace) => throw Exception(error),
        );

    var result = response.data as List;

    if (result.isEmpty) {
      throw AccountNotFoundException();
    }

    // print(response.data[0]);

    return Account.fromJson(response.data[0]);
  }

  static Future findDuplicateAccountCredentials({
    required String phoneNumber,
  }) async {
    try {
      var response = await DatabaseService.client
          .from('beneficiary_accounts')
          .select('phone_number')
          .eq(
            'phone_number',
            '$phoneNumber',
          )
          .execute()
          .onError(
            (error, stackTrace) => throw Exception(error),
          );

      if (response.error != null) {
        throw Exception(response.error!);
      }

      var result = response.data as List;

      if (result.isNotEmpty) {
        throw AccountDuplicationFoundException();
      }
    } on PostgrestError catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
        hint: stackTrace,
      );
      rethrow;
    }
  }

  static Future<bool> isDuplicatedAccount({
    required String phoneNumber,
  }) async {
    var duplicateAccount = false;
    try {
      //TODO Refactor this Method
      //If an exception is thrown return true
      await findDuplicateAccountCredentials(
        phoneNumber: phoneNumber,
      );
    } catch (e) {
      // If account is found return Duplicate account is true and thrown error message.
      duplicateAccount = !duplicateAccount; //Should evaluate to true
      rethrow;
    }
    return duplicateAccount;
  }
}
