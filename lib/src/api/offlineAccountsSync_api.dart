// import 'package:sketchy_coins/packages.dart';
// import 'package:sketchy_coins/src/services/OfflineAccountsService.dart';

// class OfflineAccountsServiceApi {
//   final offlineAccountsService = OfflineAccountsService();
//   Router get router {
//     final router = Router();

//     router.get('/download', (
//       Request request,
//     ) async {
//       return Response.forbidden(
//         json.encode({'data': offlineAccountsService.sendToRemote().toString()}),
//         headers: {
//           HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
//         },
//       );
//     });

//     return router;
//   }
// }
