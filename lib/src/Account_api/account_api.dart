import 'package:sketchy_coins/packages.dart';

class AccountApi {
  Handler get router {
    final router = Router();
    final handler = Pipeline().addMiddleware(checkAuth()).addHandler(router);

    final _accountService = AccountService();

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
    //           password: data['pin'], email: data['number']);

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

    router.get(
      '/account',
      ((
        Request request,
      ) async {
        final authDetails = request.context['authDetails'] as JWT;
        final user = _accountService.findAccount(
          accounts: _accountService.accountList,
          address: authDetails.subject.toString(),
        );
        try {
          return Response.ok(
            json.encode({
              'data': {'account': user.toJson()}
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

    return handler;
  }
}
