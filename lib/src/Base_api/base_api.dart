import 'package:sketchy_coins/packages.dart';

class BaseApi {
  Router get router {
    final router = Router();

    router.get('/status', (Request request) {
      final data = {
        'message': 'Welcome to P23',
        'status': 'Testing',
        'version': '0.0.7-alpha'
      };
      return Response.ok(
        json.encode(data),
        headers: {
          'Content-Type': 'application/json',
        },
      );
    });
    return router;
  }
}
