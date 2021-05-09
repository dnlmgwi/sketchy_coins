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
        try {
          final authDetails = request.context['authDetails'] as JWT;
          final user = await AuthValidationService.findAccount(
            id: authDetails.subject.toString(),
          );

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
        } on FormatException catch (e) {
          print('FormatException ${e.source} ${e.message}');
          return Response(
            HttpStatus.badRequest,
            body: json.encode({
              'data': {
                'message': 'Provide a valid Request refer to documentation'
              }
            }),
            headers: {
              HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
            },
          );
        } catch (e) {
          return Response(
            HttpStatus.badRequest,
            body: json.encode({
              'data': {'message': e}
            }),
            headers: {
              HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
            },
          );
        }
      }),
    );

    return handler;
  }
}
