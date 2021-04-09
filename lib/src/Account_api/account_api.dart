// import 'package:shelf_router/shelf_router.dart';
// import 'dart:convert';
// import 'package:shelf/shelf.dart';
// import 'package:sketchy_coins/src/Account_api/accountExeptions.dart';
// import 'package:sketchy_coins/src/Account_api/accountService.dart';
// import 'package:sketchy_coins/src/Blockchain_api/kkoin.dart';

// class AccountApi {
//   Router get router {
// //     final accountService = AccountService();
//     final router = Router();

//     router.post(
//       '/update',
//       ((
//         Request request, {
//         required String sender,
//         required String recipient,
//         required String amount,
//       }) async {
//         //if emptry payload
//         final payload = await request.readAsString();
//         try {
//           final data = TransactionPost.fromJson(json.decode(payload));

//           if (data.sender == '') {
//             return Response.forbidden(
//               json.encode({
//                 'data': {
//                   'message': 'Please Provide Sender Address',
//                 }
//               }),
//               headers: {
//                 'Content-Type': 'application/json',
//               },
//             );
//           }

//           if (data.recipient == '') {
//             return Response.forbidden(
//               json.encode({
//                 'data': {
//                   'message': 'Please Provide Recipient Address',
//                 }
//               }),
//               headers: {
//                 'Content-Type': 'application/json',
//               },
//             );
//           }

//           if (data.amount.isNegative || data.amount < kKoin.minAmount) {
//             return Response.forbidden(
//               json.encode({
//                 'data': {
//                   'message': 'Please include valid amount Greater Than KK10.00',
//                 }
//               }),
//               headers: {
//                 'Content-Type': 'application/json',
//               },
//             );
//           }

//           blockchain.newTransaction(
//             sender: data.sender,
//             recipient: data.recipient,
//             amount: double.parse(data.amount.toString()),
//           );

//           return Response.ok(
//             json.encode({
//               'data': {
//                 'message': 'Transaction Complete',
//                 'TransID': Uuid().v4(),
//                 'balance': 8.22,
//                 'data': json.decode(payload),
//               }
//             }),
//             headers: {
//               'Content-Type': 'application/json',
//             },
//           );
//         } catch (e) {
//           return Response.forbidden(json.encode({
//             'data': {
//               'message': 'No Data Recieved',
//             }
//           }));
//         }
//       }),
//     );

// //     router.get(
// //       '/user/<address|.*>',
// //       (Request request, String address) async {
// //         final account = accountService.findAccount(
// //           address: address,
// //           data: accountService.accountList,
// //         );

// //         if (account != null) {
// //           return Response.ok(
// //             json.encode({'data': account}),
// //             headers: {
// //               'Content-Type': 'application/json',
// //             },
// //           );
// //         } else if (account == null) {
// //           return Response.notFound(
// //             json.encode({
// //               'data': {
// //                 'message': AccountNotFoundException().toString(),
// //               }
// //             }),
// //             headers: {
// //               'Content-Type': 'application/json',
// //             },
// //           );
// //         }
// //       },
// //     );

// //     router.get(
// //       '/balance/<address|.*>',
// //       (Request request, String address) async {
// //         final account = accountService.findAccount(
// //             address: address, data: accountService.accountList);

// //         if (account != null) {
// //           return Response.ok(
// //             json.encode({
// //               'data': {
// //                 'balance': account['balance'],
// //                 'status': account['status']
// //               }
// //             }),
// //             headers: {
// //               'Content-Type': 'application/json',
// //             },
// //           );
// //         } else if (account == null) {
// //           return Response.notFound(
// //             json.encode(AccountNotFoundException().toString()),
// //             headers: {
// //               'Content-Type': 'application/json',
// //             },
// //           );
// //         } else if (address.isEmpty) {
// //           return Response.forbidden(
// //             'Please provide a valid address',
// //             headers: {
// //               'Content-Type': 'application/json',
// //             },
// //           );
// //         } else {
// //           return Response.forbidden(
// //             'Invalid Token',
// //             headers: {
// //               'Content-Type': 'application/json',
// //             },
// //           );
// //         }
// //       },
// //     );

//     return router;
//   }
// }
