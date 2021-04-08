import 'dart:io';
import 'package:shelf_router/shelf_router.dart';
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:sketchy_coins/src/Account_api/accountValidation.dart';

class AccountApi {
  Router get router {
    final data = json.decode(File('accounts.json').readAsStringSync());
    final accountValidation = AccountValidation();

    final router = Router();

    router.get(
      '/user/<address|.*>',
      (Request request, String address) async {
        final account =
            accountValidation.findAccount(address: address, data: data);

        if (account != null) {
          return Response.ok(
            json.encode({'data': account}),
            headers: {
              'Content-Type': 'application/json',
            },
          );
        } else if (account == null) {
          return Response.notFound(
            json.encode({
              'data': {'message': 'User Not Found'}
            }),
            headers: {
              'Content-Type': 'application/json',
            },
          );
        } else if (address.isEmpty) {
          return Response.forbidden(
            'Please provide a valid token',
            headers: {
              'Content-Type': 'application/json',
            },
          );
        } else {
          return Response.forbidden(
            'Invalid Token',
            headers: {
              'Content-Type': 'application/json',
            },
          );
        }
      },
    );

    router.get(
      '/balance/<address|.*>',
      (Request request, String address) async {
        final account =
            accountValidation.findAccount(address: address, data: data);

        if (account != null) {
          return Response.ok(
            json.encode({
              'data': {
                'balance': account['balance'],
                'status': account['status']
              }
            }),
            headers: {
              'Content-Type': 'application/json',
            },
          );
        } else if (account == null) {
          return Response.notFound(
            json.encode({
              'data': {'message': 'User Not Found'}
            }),
            headers: {
              'Content-Type': 'application/json',
            },
          );
        } else if (address.isEmpty) {
          return Response.forbidden(
            'Please provide a valid token',
            headers: {
              'Content-Type': 'application/json',
            },
          );
        } else {
          return Response.forbidden(
            'Invalid Token',
            headers: {
              'Content-Type': 'application/json',
            },
          );
        }
      },
    );

    return router;
  }
}
