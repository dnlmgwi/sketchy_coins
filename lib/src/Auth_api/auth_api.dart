import 'package:sketchy_coins/packages.dart';

class AuthApi {
  Box<Account> store;
  String secret;
  TokenService tokenService;

  AuthApi(
      {required this.store, required this.secret, required this.tokenService});

  Router get router {
    final router = Router();

    final _authService = AuthService();

    router.post(
      '/register',
      ((
        Request request,
      ) async {
        try {
          final payload = await request.readAsString();
          final userData = json.decode(payload);

          final email = userData['email'];
          final password = userData['password'];
          final phoneNumber = userData['phoneNumber'];

          if (email == null) {
            //Todo: Input Validation Errors
            return Response(
              HttpStatus.badRequest,
              body: json.encode({
                'data': {'account': 'Please provide a email'}
              }),
              headers: {
                HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
              },
            );
          }

          if (password == null) {
            //Todo: Input Validation Errors
            return Response(
              HttpStatus.badRequest,
              body: json.encode({
                'data': {'account': 'Please provide a password'}
              }),
              headers: {
                HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
              },
            );
          }

          if (phoneNumber == null) {
            //Todo: Input Validation Errors
            return Response(
              HttpStatus.badRequest,
              body: json.encode({
                'data': {'account': 'Please provide a number'}
              }),
              headers: {
                HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
              },
            );
          }

          //TODO: Change Account Fields
          _authService.register(
            password: password,
            email: email,
            phoneNumber: phoneNumber,
          );

          return Response.ok(
            json.encode({
              'data': {'message': 'Account Created'}
            }),
            headers: {
              HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
            },
          );
        } catch (e) {
          print(e.toString());
          return Response(
            HttpStatus.badRequest,
            body: json.encode({
              'data': {'message': 'Email, Password & PhoneNumber Keys Required'}
            }),
            headers: {
              HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
            },
          );
        }
      }),
    );

    router.post(
      '/login',
      ((
        Request request,
      ) async {
        try {
          final payload = await request.readAsString();

          final userData = json.decode(payload);

          final address = userData['address'];
          final password = userData['password'];

          if (address == null) {
            //Todo: Input Validation Errors
            return Response(
              HttpStatus.badRequest,
              body: json.encode({
                'data': {'message': 'Please provide an address'}
              }),
              headers: {
                HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
              },
            );
          }

          if (password == null) {
            //Todo: Input Validation Errors
            return Response(
              HttpStatus.badRequest,
              body: json.encode({
                'data': {'message': 'Please provide a password'}
              }),
              headers: {
                HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
              },
            );
          }

          //TODO: Change Account Fields
          final token = await _authService.login(
            password: password,
            address: address,
            tokenService: tokenService,
          );

          return Response.ok(
            json.encode({'data': token.toJson()}),
            headers: {
              HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
            },
          );
        } catch (e) {
          print(e.toString());
          return Response(
            HttpStatus.badRequest,
            body: json.encode({
              'data': {'message': 'Address & Password Keys Required'}
            }),
            headers: {
              HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
            },
          );
        }
      }),
    );

    router.post('/logout', (Request req) async {
      final auth = req.context['authDetails'];
      if (auth == null) {
        return Response.forbidden(
          json.encode({
            'data': {'message': 'Not authorised to perform this request'}
          }),
          headers: {
            HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
          },
        );
      }

      try {
        await tokenService.removeRefreshToken((auth as JWT).jwtId);
      } catch (e) {
        return Response.internalServerError(
            body: json.encode({
              'data': {
                'message':
                    'There was an issue logging out. Please check and try again.'
              }
            }),
            headers: {
              HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
            });
      }

      return Response.ok(
        json.encode({
          'data': {'message': 'Successfully logged out'}
        }),
        headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
        },
      );
    });

    router.post('/refreshToken', (Request req) async {
      //TODO: Error thrown by handler. type 'Null' is not a subtype of type 'String'

      final payload = await req.readAsString();
      final payloadMap;
      final JWT token;

      try {
        payloadMap = json.decode(payload);
        token = verifyJWT(
          token: payloadMap['refreshToken'],
          secret: secret,
        );
      } catch (e) {
        print(e.toString());
        return Response(
          HttpStatus.badRequest,
          body: json.encode({
            'data': {'message': 'refreshToken Key Required'}
          }),
          headers: {
            HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
          },
        );
      }

      if (token.payload == null) {
        return Response(HttpStatus.badRequest,
            body: json.encode({
              'data': {'message': 'Refresh token is not valid.'}
            }),
            headers: {
              HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
            });
      }

      final dbToken = await tokenService.getRefreshToken(token.jwtId);

      if (dbToken == null) {
        return Response(HttpStatus.badRequest,
            body: json.encode({
              'data': {'message': 'Refresh token is not recognised.'}
            }),
            headers: {
              HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
            });
      }
      // Generate new token pair
      final oldJwt = token;
      try {
        await tokenService.removeRefreshToken(
          token.jwtId,
        );
        final tokenPair = await tokenService.createTokenPair(
          userId: oldJwt.subject,
        );
        return Response.ok(
          json.encode(tokenPair.toJson()),
          headers: {
            HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
          },
        );
      } catch (e) {
        return Response.internalServerError(
            body: json.encode({
              'data': {
                'message':
                    'There was a problem creating a new token. Please try again.'
              }
            }),
            headers: {
              HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
            });
      }
    });
    return router;
  }
}
