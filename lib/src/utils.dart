import 'package:sketchy_coins/packages.dart';

Middleware handleCors() {
  const corsHeaders = {'Access-Control-Allow-Origin': '*'};

  return createMiddleware(requestHandler: (Request request) {
    if (request.method == 'OPTIONS') {
      return Response.ok('', headers: corsHeaders);
    }
    return null;
  }, responseHandler: (Response response) {
    return response.change(headers: corsHeaders);
  });
}

String generateSalt([int length = 32]) {
  final random = Random.secure();
  final saltbytes = List<int>.generate(length, (_) => random.nextInt(256));
  return base64.encode(saltbytes);
}

String hashPassword({required String password, required String salt}) {
  final codec = Utf8Codec();
  final key = codec.encode(password);
  final saltbytes = codec.encode(salt);
  final hmac = Hmac(sha256, key);
  final digest = hmac.convert(saltbytes);
  return digest.toString();
}

String generateJWT(
    {required String? subject,
    required String issuer,
    required String secret,
    String? jwtId,
    //TODO: Review JWT Validy Period
    Duration expiry = const Duration(seconds: 20)}) {
  // Create a json web token
  final jwt = JWT(
    {
      'iat': DateTime.now().millisecondsSinceEpoch,
    },
    subject: subject,
    issuer: Env.issuer,
    jwtId: jwtId,
  );
  return jwt.sign(
    SecretKey(secret),
    expiresIn: expiry,
  );
}

dynamic verifyJWT({required String token, required String secret}) {
  try {
    final jwt = JWT.verify(token, SecretKey(secret));
    return jwt;
  } on JWTExpiredError {
    rethrow;
  } on JWTError catch (e) {
    print(e.message);
    rethrow;
  }
}

Middleware handleAuth({required String secret}) {
  return (Handler innerhandler) {
    return (Request request) async {
      final authHeader = request.headers['authorization'];
      var token, jwt;

      if (authHeader != null && authHeader.startsWith('Bearer ')) {
        token = authHeader.substring(7);
        jwt = verifyJWT(
            token: token,
            secret:
                secret); //TODO: Handle: JWTUndefinedError: JWTExpiredError: jwt expired
      }

      final updateRequest = request.change(context: {
        'authDetails': jwt,
      });

      return await innerhandler(updateRequest);
    };
  };
}

Middleware checkAuth() {
  return createMiddleware(requestHandler: (Request request) {
    if (request.context['authDetails'] == null) {
      return Response.forbidden('Not authorised to perform this request');
    }
    return null;
  });
}

Middleware checkAuthorisation() {
  return createMiddleware(
    requestHandler: (Request request) {
      if (request.context['authDetails'] == null) {
        return Response.forbidden('Not authorised to perform this action.');
      }
      return null;
    },
  );
}
