import 'package:sketchy_coins/packages.dart';

class AccountService {
  DatabaseService databaseService;
  AccountService({required this.databaseService});

  Future<Account> findAccount({required String address}) async {
    var response = await databaseService.client
        .from('accounts')
        .select(
          'id,email,phoneNumber,password, salt,status,balance,joinedDate, address',
        )
        .match({
          'address': address,
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

  Future<List> findAccounts({
    required String recipient,
    required String sender,
  }) async {
    var response = await databaseService.client
        .from('accounts')
        .select(
          'address',
        )
        .in_('address', ['$sender', '$recipient'])
        .execute()
        .onError(
          (error, stackTrace) => throw Exception(error),
        );

    var result = response.data as List;

    if (result.isEmpty) {
      throw AccountNotFoundException();
    }

    return result;
  }
}
