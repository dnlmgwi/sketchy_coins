import 'package:sketchy_coins/packages.dart';

abstract class IAuthService {
  Future register({
    required String password,
    required int age,
    required String gender,
    required String phoneNumber,
  });

  Future<TokenPair> login({
    required String password,
    required String id, //TODO Login with phoneNumber aswell
    required TokenService tokenService,
  });
}
