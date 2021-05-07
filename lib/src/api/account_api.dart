import 'package:sketchy_coins/packages.dart';

class AccountApi {
  AuthService authService;
  DatabaseService databaseService;

  AccountApi({
    required this.databaseService,
    required this.authService,
  });

  Handler get router {
    final router = Router();
    final handler = Pipeline().addMiddleware(checkAuth()).addHandler(router);

    router.get(
      '/account',
      ((
        Request request,
      ) async {
        final authDetails = request.context['authDetails'] as JWT;
        final user = await authService.findAccount(
          id: authDetails.subject.toString(),
        );
        try {
          return Response.ok(
            json.encode({
              'data': {
                'account': user.toJson(),
              }
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
