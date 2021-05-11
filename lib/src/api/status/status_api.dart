import 'package:sketchy_coins/packages.dart';

class StatusApi {
  Router get router {
    final router = Router();

    router.get('/status', (Request request) {
      final data = {
        'message': 'Welcome to Perrow API',
        'status': 'Testing',
        'version': '0.5.1-alpha',
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
