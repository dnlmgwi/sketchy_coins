import 'package:sketchy_coins/packages.dart';

abstract class IAuthService {
  Future register({
    required String pin,
    required int age,
    required String gender,
    required String phoneNumber,
  });

  Future<TokenPair> login({
    required String pin,
    required String id,
    required TokenService tokenService,
  });
}
