import 'package:sketchy_coins/packages.dart';

class AuthService {
  DatabaseService databaseService;

  AuthService({
    required this.databaseService,
  });

  Future<Account> findAccount({required String address}) async {
    var response = await DatabaseService.client
        .from('accounts')
        .select(
          'id,email,phoneNumber,password,address, balance, salt, status,joinedDate',
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

  Future findDuplicateAccountCredentials({
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
          .execute();

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

  Future<bool> isNotDuplicatedAccount({
    required String email,
    required String phoneNumber,
  }) async {
    var duplicateAccount = false;
    try {
      await findDuplicateAccountCredentials(
        email: email,
        phoneNumber: phoneNumber,
      );
    } catch (e) {
      // If account is found return Duplicate account is true and thrown error message.
      duplicateAccount = true;
      rethrow;
    }
    return duplicateAccount;
  }

  Future register({
    required String password,
    required String email,
    required String phoneNumber,
  }) async {
    final salt = generateSalt();

    final hashpassword = hashPassword(
      password: password,
      salt: salt,
    );

    final address = userAddressAlgo(
      phoneNumber: phoneNumber,
    );

    try {
      var response;
      var isDuplicate = await isNotDuplicatedAccount(
        email: email,
        phoneNumber: phoneNumber,
      );
      if (!isDuplicate) {
        response = await DatabaseService.client.from('accounts').insert(
          [
            Account(
              email: email,
              address: address,
              phoneNumber: phoneNumber,
              password: hashpassword,
              salt: salt,
              status: 'normal',
              balance: double.parse(Env.newAccountBalance),
              joinedDate: DateTime.now().millisecondsSinceEpoch,
            ).toJson()
          ],
        ).execute();
      }

      if (response.error != null) {
        throw response.error!.message;
      }
      return response.data;
    } on PostgrestError catch (e) {
      print(e.code);
      print(e.message);
      rethrow;
    }
  }

  Future<TokenPair> login({
    required String password,
    required String address,
    required TokenService tokenService,
  }) async {
    Account user;
    TokenPair tokenPair;

    try {
      user = await findAccount(
        address: address,
      );

      final hashpassword = hashPassword(
        password: password,
        salt: user.salt,
      );

      if (hashpassword != user.password) {
        throw IncorrectInputException();
      }

      tokenPair = await tokenService.createTokenPair(userId: user.address);
    } catch (e) {
      rethrow;
    }

    return tokenPair;
  }
}
