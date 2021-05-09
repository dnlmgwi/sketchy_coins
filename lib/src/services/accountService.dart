import 'package:sketchy_coins/packages.dart';

class AccountService implements IAccountService {
  DatabaseService databaseService;
  AccountService({required this.databaseService});

  @override
  Future<TransAccount> findAccountDetails({required String id}) async {
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

  @override
  Future<TransAccount> findRecipientDepositAccount(
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
