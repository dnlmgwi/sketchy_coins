import 'package:sketchy_coins/packages.dart';

class TokenService {
  TokenService({
    required this.secret,
  });
  
  final String secret;
  late RedisClient client;

  final String _prefix = 'token';
  final refreshTokenExpiry = Duration(days: 7); //TODO: 7 Days is best practice?

  Future<void> start() async {
    try {
      client = await RedisClient.connect(
        Env.redisHostname,
        int.parse(
          Env.redisPort,
        ),
      );
    } catch (e) {
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
        expiry: Duration(minutes: 15));

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
      '$_prefix: $id',
      Duration(
        days: expiry.inSeconds,
      ),
    );
  }

  Future<dynamic> getRefreshToken(String? id) async {
    return await client.get('$_prefix: $id');
  }

  Future<void> removeRefreshToken(String? id) async {
    await client.expire('$_prefix: $id', Duration(seconds: -1));
  }
}
