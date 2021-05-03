// import 'package:sketchy_coins/packages.dart';
// import 'package:sketchy_coins/src/services/OfflineAccountsService.dart';

// class OfflineAccountsServiceApi {
//   final offlineAccountsService = OfflineAccountsService();
//   Router get router {
//     final router = Router();

//     router.post(
//       '/upload',
//       ((
//         Request request,
//       ) async {
//         final payload = await request.readAsString();

//         try {
//           //TODO:

//           return Response.ok(
//             json.encode({
//               'data': {
//                 'message': 'Transaction Complete',
//                 'transaction': json.decode(payload),
//               }
//             }),
//             headers: {
//               HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
//             },
//           );
//         } catch (e) {
//           print(e);

//           return Response.forbidden(
//             json.encode({
//               'data': {'message': '${e.toString()}'}
//             }),
//             headers: {
//               HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
//             },
//           );
//         }
//       }),
//     );

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
