import 'package:sketchy_coins/packages.dart';
import 'package:sketchy_coins/src/Models/account/transAccount.dart';

class AccountService {
  DatabaseService databaseService;
  AccountService({required this.databaseService});

  Future<TransAccount> findAccount({required String id}) async {
    var response = await DatabaseService.client
        .from('accounts')
        .select(
          'status, balance, id, phoneNumber, lastTrans',
        )
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

    return TransAccount.fromJson(response.data[0]);
  }

  Future<TransAccount> findRecipientAccount(
      {required String phoneNumber}) async {
    var response = await DatabaseService.client
        .from('accounts')
        .select(
          'status, balance, id, phoneNumber, lastTrans',
        )
        .match({
          'phoneNumber': phoneNumber,
        })
        .execute()
        .onError(
          (error, stackTrace) => throw Exception(error),
        );

    var result = response.data as List;

    if (result.isEmpty) {
      throw AccountNotFoundException();
    }

    return TransAccount.fromJson(response.data[0]);
  }
}
