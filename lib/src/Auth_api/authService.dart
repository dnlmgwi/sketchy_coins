import 'dart:math';

import 'package:hive/hive.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:sketchy_coins/src/Auth_api/EnvValues.dart';
import 'package:sketchy_coins/src/Models/JWT/jwtModel.dart';

/// [Header]
/// represented by the first section
/// contains information about the algorithm used to encrypt data
///
/// [Payload]
/// represented by the second section
/// contains the actual claims data
///
/// [Signature]
/// represented by the third section
/// signature of the JWT issuing server
///
/// [Base64-URL encoded header].[Base64-URL encoded payload].[Signature]
abstract class AuthService {
  var jwtStore = Hive.box<JWTModel>('jwt');

  void addToDatabase(String token) {
    jwtStore.add(JWTModel(jwt: token));
  }

  String createJwt(Map<String, dynamic> payload) {
    // Create a claim set
    final claimSet = JwtClaim(
      issuer: enviromentVariables.issuer,
      subject: enviromentVariables.subject,
      audience: <String>['app.kotg.club', 'api.kotg.club'],
      jwtId: _randomString(32),
      payload: payload,
      maxAge: const Duration(minutes: 5),
      otherClaims: <String, dynamic>{
        'typ': enviromentVariables.typ,
      },
    );

    // Generate a JWT from the claim set
    final token = issueJwtHS256(claimSet,
        enviromentVariables.jwt_auth_sharedSecret); //TODO: Create Shared Secret

    print('JWT: "$token"\n');
    jwtStore.add(
      JWTModel(
        jwt: token,
      ),
    );
    return token;
  }

  void processJwt(JWTModel token) {
    try {
      // Verify the signature in the JWT and extract its claim set
      final decClaimSet = verifyJwtHS256Signature(
          token.jwt, enviromentVariables.jwt_auth_sharedSecret);
      print('JwtClaim: $decClaimSet\n');

      // Validate the claim set

      decClaimSet.validate(issuer: 'teja', audience: 'client2.example.com');

      // Use values from claim set

      if (decClaimSet.jwtId != null) {
        print('JWT ID: "${decClaimSet.jwtId}"');
      }
      if (decClaimSet.subject != null) {
        print('Subject: "${decClaimSet.subject}"');
      }
      if (decClaimSet.issuedAt != null) {
        print('Issued At: ${decClaimSet.issuedAt}');
      }
      if (decClaimSet.containsKey('typ')) {
        final dynamic v = decClaimSet['typ'];
        if (v is String) {
          print('typ: "$v"');
        } else {
          print('Error: unexpected type for "typ" claim');
        }
      }
    } on JwtException catch (e) {
      print('Error: bad JWT: $e');
    }
  }

  String _randomString(int length) {
    const chars =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
    final rnd = Random(DateTime.now().millisecondsSinceEpoch);
    final buf = StringBuffer();

    for (var x = 0; x < length; x++) {
      buf.write(chars[rnd.nextInt(chars.length)]);
    }
    return buf.toString();
  }
  //ENV
  //Create Refresh Token
  //client first checks if the access token has expired or not
  //If the token hasn’t expired, then the client makes API call with the valid access token.
  //However, if the token has expired, the client should renew the access token first.
  //So, the server receives a request to renew the access token in which the client passes both the refresh token and user’s id for verification.
  // The server then looks up if there is a matching entry for refresh token and user id pair in the database.
  // The client then updates the new access token in it’s local database. Any subsequent calls to server are made with this new access token for requesting resource.
}
