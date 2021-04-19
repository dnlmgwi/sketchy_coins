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

          if (email.isEmpty || email == null) {
            //Todo: Input Validation Errors
            return Response(
              HttpStatus.badRequest,
              body: 'Please provide a email',
              headers: {
                'Content-Type': 'application/json',
              },
            );
          }

          if (password.isEmpty || password == null) {
            //Todo: Input Validation Errors
            return Response(
              HttpStatus.badRequest,
              body: 'Please provide a number',
              headers: {
                'Content-Type': 'application/json',
              },
            );
          }

          if (phoneNumber.isEmpty || phoneNumber == null) {
            //Todo: Input Validation Errors
            return Response(
              HttpStatus.badRequest,
              body: 'Please provide a number',
              headers: {
                'Content-Type': 'application/json',
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
              'Content-Type': 'application/json',
            },
          );
        } catch (e) {
          print(e);
          return Response.forbidden(
            json.encode({
              'data': {'message': '${e.toString()}'}
            }),
            headers: {
              'Content-Type': 'application/json',
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

          if (address.isEmpty || address == null) {
            //Todo: Input Validation Errors
            return Response(
              HttpStatus.badRequest,
              body: 'Please provide a address',
              headers: {
                'Content-Type': 'application/json',
              },
            );
          }

          if (password.isEmpty || password == null) {
            //Todo: Input Validation Errors
            return Response(
              HttpStatus.badRequest,
              body: 'Please provide a password',
              headers: {
                'Content-Type': 'application/json',
              },
            );
          }

          //TODO: Change Account Fields
          final token = await _authService.login(
              password: password, address: address, tokenService: tokenService);

          return Response.ok(
            json.encode({'data': token.toJson()}),
            headers: {
              'Content-Type': 'application/json',
            },
          );
        } catch (e) {
          print(e);
          return Response.forbidden(
            json.encode({
              'data': {'message': '${e.toString()}'}
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
        return Response.forbidden('Not authorised to perform this operation.');
      }

      try {
        await tokenService.removeRefreshToken((auth as JWT).jwtId);
      } catch (e) {
        return Response.internalServerError(
            body:
                'There was an issue logging out. Please check and try again.');
      }

      return Response.ok('Successfully logged out');
    });

    router.post('/refreshToken', (Request req) async {
      final payload = await req.readAsString();
      final payloadMap = json.decode(payload);

      final JWT token = verifyJWT(
        token: payloadMap['refreshToken'],
        secret: secret,
      );

      if (token.payload == null) {
        return Response(400, body: 'Refresh token is not valid.');
      }

      final dbToken = await tokenService.getRefreshToken(token.jwtId);
      if (dbToken == null) {
        return Response(400, body: 'Refresh token is not recognised.');
      }

      // Generate new token pair
      final oldJwt = token;
      try {
        await tokenService.removeRefreshToken(token.jwtId);

        final tokenPair =
            await tokenService.createTokenPair(userId: oldJwt.subject);
        return Response.ok(
          json.encode(tokenPair.toJson()),
          headers: {
            HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
          },
        );
      } catch (e) {
        return Response.internalServerError(
            body:
                'There was a problem creating a new token. Please try again.');
      }
    });

    router.get(
      '/accounts',
      ((
        Request request,
      ) async {
        try {
          return Response.ok(
            json.encode({
              'data': {'accounts': _authService.accountList.values.toList()}
            }),
            headers: {
              'Content-Type': 'application/json',
            },
          );
        } catch (e) {
          print(e);
        }
      }),
    );

    return router;
  }
}
