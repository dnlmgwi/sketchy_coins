import 'package:sketchy_coins/p23_blockchain.dart';

class AccountApi {
  Router get router {
    final router = Router();

    final _accountService = AccountService();

    router.post(
      '/create',
      ((
        Request request,
      ) async {
        try {
          final payload = await request.readAsString();
          final data = json.decode(payload);

          if (data['number'] == '') {
            return Response.forbidden(
              json.encode({
                'data': {
                  'message': 'Please provide a Number',
                }
              }),
              headers: {
                'Content-Type': 'application/json',
              },
            );
          }

          if (data['pin'] == '') {
            return Response.forbidden(
              json.encode({
                'data': {
                  'message': 'Please provide a PIN',
                }
              }),
              headers: {
                'Content-Type': 'application/json',
              },
            );
          }

          _accountService.createAccount(
              pin: data['pin'], number: data['number']);

          return Response.ok(
            json.encode({
              'data': {
                'message': 'Account Created',
                'details': data,
                'address':
                    '${_accountService.identityHash('${data['pin']}${data['number']}')}'
              }
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

    router.get(
      '/accounts',
      ((
        Request request,
      ) async {
        try {
          return Response.ok(
            json.encode({
              'data': {'accounts': _accountService.accountList.values.toList()}
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
