import 'dart:convert';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:sketchy_coins/src/Blockchain_api/blockchain_api.dart';

void main(List<String> arguments) async {
  var app = Router();
  final _hostName = 'localhost';
  final _port = 8081;
  var server = await io.serve(app, _hostName, _port);
  print('Serving at http://${server.address.host}:${server.port}');

  final data = {
    'message': 'Welcome to the KKoin.',
    'status': 'Testing',
    'version': '0.0.0-alpha',
    'activeEndpoints': [
      'http://$_hostName:$_port/v1/chain',
      'http://$_hostName:$_port/v1/transactions/create',
      'http://$_hostName:$_port/v1/mine'
    ]
  };

  app.get('/', (Request request) async {
    return Response.ok(
      json.encode(data),
      headers: {
        'Content-Type': 'application/json',
      },
    );
  });

  //v1 of KKoin Api
  app.mount('/v1/', BlockChainApi().router);
}
