import 'package:sketchy_coins/packages.dart';

abstract class IAuthService {
  Future register({
    required String password,
    required String email,
    required String phoneNumber,
  });

  Future<TokenPair> login({
    required String password,
    required String id,
    required TokenService tokenService,
  });
}
