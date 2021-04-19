import 'package:sketchy_coins/packages.dart';

class TokenService {
  TokenService({
    required this.secret,
  });
  final String secret;
  late RedisClient client;

  final String _prefix = 'token';
  final refreshTokenExpiry = Duration(seconds: 20); //TODO: Increase Duration

  Future<void> start() async {
    try {
      client = await RedisClient.connect(
        Env.redisHostname,
        int.parse(
          Env.redisPort,
        ),
      );
    } catch (e) {
      //TODO: Provide alternative redis when not available
      rethrow;
    }
  }

  Future<TokenPair> createTokenPair({required String? userId}) async {
    final tokenId = Uuid().v4();

    final token = generateJWT(
      subject: userId,
      issuer: Env.hostName,
      secret: secret,
      jwtId: tokenId,
    );

    final refreshToken = generateJWT(
      subject: userId,
      issuer: Env.hostName,
      secret: secret,
      jwtId: Uuid().v4(),
      expiry: refreshTokenExpiry,
    );

    await addRefreshToken(
      id: tokenId,
      token: refreshToken,
      expiry: refreshTokenExpiry,
    );

    return TokenPair(token: token, refreshToken: refreshToken);
  }

  Future<void> addRefreshToken({
    required String id,
    required String token,
    required Duration expiry,
  }) async {
    await client.set('$_prefix:$id', token);
    await client.expire(
      '$_prefix:$id',
      Duration(
        seconds: expiry.inSeconds,
      ),
    );
  }

  Future<dynamic> getRefreshToken(String? id) async {
    return await client.get('$_prefix:$id');
  }

  Future<dynamic> deleteCache() async {
    return await client.deleteAllDBs();
  }

  Future<void> removeRefreshToken(String? id) async {
    await client.expire('$_prefix:$id', Duration(seconds: -1));
  }
}
