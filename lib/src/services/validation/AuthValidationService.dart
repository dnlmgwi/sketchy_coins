import 'package:sketchy_coins/packages.dart';

class AuthValidationService {
  static Future<Account> findAccount({required String id}) async {
    var response = await DatabaseService.client
        .from('accounts')
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

    return Account.fromJson(response.data[0]);
  }

  static Future findDuplicateAccountCredentials({
    required String email,
    required String phoneNumber,
  }) async {
    try {
      var response = await DatabaseService.client
          .from('accounts')
          .select('email,phoneNumber')
          .or(
            'email.eq.$email, phoneNumber.eq.$phoneNumber',
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
    } on PostgrestError catch (e) {
      print(e.code);
      print(e.message);
      rethrow;
    }
  }

  static Future<bool> isDuplicatedAccount({
    required String email,
    required String phoneNumber,
  }) async {
    var duplicateAccount = false;
    try {
      //TODO Refactor this Method
      //If an exception is thrown return true
      await findDuplicateAccountCredentials(
        email: email,
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
