import 'dart:convert';
import 'dart:io';

import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:sketchy_coins/blockchain_api.dart';

void main(List<String> arguments) async {
  var app = Router();

  var server = await io.serve(app, 'localhost', 8080);
  print('Serving at http://${server.address.host}:${server.port}');

  final Map data = json.decode(File('default.json').readAsStringSync());

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
