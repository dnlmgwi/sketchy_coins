import 'package:sketchy_coins/packages.dart';

class AccountApi {
  Handler get router {
    final router = Router();
    final handler = Pipeline().addMiddleware(checkAuth()).addHandler(router);

    final _accountService = AccountService();

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
              HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
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
