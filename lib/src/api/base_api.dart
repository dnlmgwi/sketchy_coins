import 'package:sketchy_coins/packages.dart';

class BaseApi {
  var accountService = AccountService();
  Router get router {
    final router = Router();

    router.get('/status', (Request request) {
      final data = {
        'message': 'Welcome to P23',
        'status': 'Testing',
        'version': '0.1.6-alpha',
      };
      return Response.ok(
        json.encode(data),
        headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
        },
      );
    });

    router.get('/accounts', (Request request) {
      final data = {
        'accounts': accountService.accountList.values
            .toList()
            .map((e) => e.toJson())
            .toList(),
        'users': '${accountService.accountListCount}'
      };
      return Response.ok(
        json.encode(data),
        headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
        },
      );
    });

    return router;
  }
}
