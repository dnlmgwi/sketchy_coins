import 'package:sketchy_coins/packages.dart';

class AuthService implements IAuthService {
  DatabaseService databaseService;

  AuthService({
    required this.databaseService,
  });

  @override
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

    try {
      var response;
      var isDuplicate = await AuthValidationService.isDuplicatedAccount(
        email: email,
        phoneNumber: phoneNumber,
      );

      if (!isDuplicate) {
        response = await DatabaseService.client.from('accounts').insert(
          [
            Account(
              email: email,
              // id: id,
              phoneNumber: phoneNumber,
              password: hashpassword,
              salt: salt,
              status: 'normal',
              balance: double.parse(Env.newAccountBalance!),
              joinedDate: DateTime.now().millisecondsSinceEpoch,
            ).toJson()
          ],
        ).execute(); //TODO Handle Error
      }

      if (response.error != null) {
        throw response.error!.message;
      }

      return response.data; //TODO Should it return this data?

    } on PostgrestError catch (e) {
      print(e.code);
      print(e.message);
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<TokenPair> login({
    required String password,
    required String id,
    required TokenService tokenService,
  }) async {
    Account user;
    TokenPair tokenPair;

    try {
      user = await AuthValidationService.findAccount(
        id: id,
      );

      final hashpassword = hashPassword(
        password: password,
        salt: user.salt,
      );

      if (hashpassword != user.password) {
        throw IncorrectInputException();
      }

      tokenPair = await tokenService.createTokenPair(userId: user.id);
    } catch (e) {
      rethrow;
    }

    return tokenPair;
  }
}
