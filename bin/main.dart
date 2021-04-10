import 'dart:convert';
import 'dart:io';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:sketchy_coins/src/Blockchain_api/blockchain_api.dart';

void main(List<String> arguments) async {
  var handler = Router();

  var portEnv = Platform.environment['PORT'];

  final _hostName = '0.0.0.0';
  final _port = portEnv == null ? 9999 : int.parse(portEnv);
  ;
  var server = await io.serve(handler, _hostName, _port);
  print('Serving at http://${server.address.host}:${server.port}');

  handler.get('/', (Request request) {
    final data = {
      'message': 'Welcome to the KKoin.',
      'status': 'Testing',
      'version': '0.0.0-alpha',
      'activeEndpoints': [
        'http://$_hostName:$_port/v1/blockchain/chain',
        'http://$_hostName:$_port/v1/blockchain/transactions/create',
        'http://$_hostName:$_port/v1/blockchain/mine',
        'http://$_hostName:$_port/v1/account/transactions/pay',
        'http://$_hostName:$_port/v1/account/balance'
      ]
    };
    return Response.ok(
      json.encode(data),
      headers: {
        'Content-Type': 'application/json',
      },
    );
  });

  //v1 of KKoin Api
  handler.mount('/v1/blockchain/', BlockChainApi().router);
  // app.mount('/v1/account/', AccountApi().router);
}
