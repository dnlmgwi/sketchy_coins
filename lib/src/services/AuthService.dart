import 'package:sentry/sentry.dart';
import 'package:sketchy_coins/packages.dart';

class AuthService implements IAuthService {
  @override
  Future register({
    required String password,
    required String gender,
    required int age,
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
        phoneNumber: phoneNumber,
      );

      if (!isDuplicate) {
        response = await DatabaseService.client
            .from('beneficiary_accounts')
            .insert(Account(
              id: Uuid().v4(),
              age: age,
              gender: gender,
              phoneNumber: phoneNumber,
              password: hashpassword,
              salt: salt,
              status: 'normal',
              balance: int.parse(Env.newAccountBalance!),
              joinedDate: DateTime.now().millisecondsSinceEpoch,
            ).toJson())
            .execute()
            .catchError(
          (exception, stackTrace) async {
            await Sentry.captureException(
              exception,
              stackTrace: stackTrace,
            );
          },
        ); //TODO Muliple Fails Alert People In Area.
      }

      if (response.error != null) {
        throw Exception(response.error!.message);
      }

      print(response.data); //TODO Notify User Once Account Is Created

      return response.data; //TODO Should it return this data?

    } on PostgrestError catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
        hint: stackTrace,
      );
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
