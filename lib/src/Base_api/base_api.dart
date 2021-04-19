import 'package:sketchy_coins/packages.dart';

class BaseApi {
  var accountService = AccountService();
  Router get router {
    final router = Router();

    router.get('/status', (Request request) {
      final data = {
        'message': 'Welcome to P23',
        'status': 'Testing',
        'version': '0.1.3-alpha',
        'accounts': '${accountService.accountList.values.last.toJson()}'
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
