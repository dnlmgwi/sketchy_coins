import 'package:sketchy_coins/packages.dart';

class AuthApi {
  Box<Account> store;
  String secret;

  AuthApi({required this.store, required this.secret});

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
          final token =
              _authService.login(password: password, address: address);

          return Response.ok(
            json.encode({
              'data': {'token': token}
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
              HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
            },
          );
        }
      }),
    );

    router.post(
      '/logout',
      ((
        Request request,
      ) async {
        if (request.context['authDetails'] == null) {
          return Response.forbidden(
            'Not Authorised to perform this action',
            headers: {
              'Content-Type': 'application/json',
            },
          );
        }

        return Response.ok('Successfully Logged Out');
      }),
    );

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
