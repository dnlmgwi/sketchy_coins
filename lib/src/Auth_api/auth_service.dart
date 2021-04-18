import 'package:sketchy_coins/packages.dart';
import 'package:sketchy_coins/src/Auth_api/AuthService.dart';

class AuthApi {
  Box store;
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
          _authService.register(password: password, email: email);

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

    // router.post(
    //   '/create',
    //   ((
    //     Request request,
    //   ) async {
    //     try {
    //       final payload = await request.readAsString();
    //       final data = json.decode(payload);

    //       if (data['number'] == '') {
    //         return Response.forbidden(
    //           json.encode({
    //             'data': {
    //               'message': 'Please provide a Number',
    //             }
    //           }),
    //           headers: {
    //             'Content-Type': 'application/json',
    //           },
    //         );
    //       }

    //       if (data['pin'] == '') {
    //         return Response.forbidden(
    //           json.encode({
    //             'data': {
    //               'message': 'Please provide a PIN',
    //             }
    //           }),
    //           headers: {
    //             'Content-Type': 'application/json',
    //           },
    //         );
    //       }

    //       _accountService.createAccount(
    //           pin: data['pin'], number: data['number']);

    //       return Response.ok(
    //         json.encode({
    //           'data': {
    //             'message': 'Account Created',
    //             'details': data,
    //             'address':
    //                 '${_accountService.identityHash('${data['pin']}${data['number']}')}'
    //           }
    //         }),
    //         headers: {
    //           'Content-Type': 'application/json',
    //         },
    //       );
    //     } catch (e) {
    //       print(e);
    //       return Response.forbidden(
    //         json.encode({
    //           'data': {'message': '${e.toString()}'}
    //         }),
    //         headers: {
    //           'Content-Type': 'application/json',
    //         },
    //       );
    //     }
    //   }),
    // );

    // router.get(
    //   '/accounts',
    //   ((
    //     Request request,
    //   ) async {
    //     try {
    //       return Response.ok(
    //         json.encode({
    //           'data': {'accounts': _accountService.accountList.values.toList()}
    //         }),
    //         headers: {
    //           'Content-Type': 'application/json',
    //         },
    //       );
    //     } catch (e) {
    //       print(e);
    //     }
    //   }),
    // );

    return router;
  }
}
