import 'package:sketchy_coins/packages.dart';
// import 'package:steel_crypt/steel_crypt.dart';

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

String hashPin({required String pin, required String salt}) {
  final codec = Utf8Codec();
  final key = codec.encode(pin);
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
    Duration expiry = const Duration(
      minutes: 20,
    )}) {
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
  } on JWTExpiredError catch (e) {
    print('JWTExpiredError ${e.message}');
    rethrow;
  } on JWTError catch (e) {
    print('JWTError $e');
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

        try {
          jwt = verifyJWT(token: token, secret: secret);
        } catch (e) {
          print('Handler Auth Error: ${e.toString()}');
          //Todo Notify Auth Error
        }
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
      return Response.forbidden(
        json.encode({
          'data': {'message': 'Not authorised to perform this request'}
        }),
        headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
        },
      );
    }
    return null;
  });
}

Middleware checkAuthorisation() {
  return createMiddleware(
    requestHandler: (Request request) {
      if (request.context['authDetails'] == null) {
        return Response.forbidden(
            json.encode({
              'data': {'message': 'Not authorised to perform this request'}
            }),
            headers: {
              HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
            });
      }
      return null;
    },
  );
}
