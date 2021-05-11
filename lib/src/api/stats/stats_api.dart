import 'package:sketchy_coins/packages.dart';
import 'package:sketchy_coins/src/services/statisticsService/statisticsService.dart';

class StatsApi {
  StatisticsService statsService;

  StatsApi({
    required this.statsService,
  });

  Router get router {
    final router = Router();

    router.get('/numbers/<term>', (Request request, String term) async {
      final data = await statsService.queryStats(term);
      return Response.ok(
        json.encode(data),
        headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
        },
      );
    });

    router.get('/text/<column>/<term>',
        (Request request, String column, String term) async {
      final data = await statsService.queryFreqStats(column, term);
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
