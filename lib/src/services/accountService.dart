import 'package:sketchy_coins/packages.dart';
import 'package:sketchy_coins/src/Models/account/transAccount.dart';

class AccountService {
  DatabaseService databaseService;
  AccountService({required this.databaseService});

  Future<TransAccount> findAccount({required String address}) async {
    var response = await DatabaseService.client
        .from('accounts')
        .select(
          'status, balance, address',
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

    return TransAccount.fromJson(response.data[0]);
  }
}
