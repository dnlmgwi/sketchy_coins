import 'package:sketchy_coins/packages.dart';

class Env {
  //Server Side
  static final envPort = Platform.environment['PORT'];
  static const localPort = '8080';
  static String port = envPort ?? localPort;
  static var hostName = '0.0.0.0';

  //Reward System Address
  static final envSystemAddress = Platform.environment['SYSTEM_ADDRESS'];
  static const localSystemAddress = 'Testing-Admin';
  static String systemAddress = envSystemAddress ?? localSystemAddress;

  //Database
  // static const postgresqlUrl = _Env.postgresqlUrl;
  //Cache
  static final envRedisPort = Platform.environment['REDIS_PORT'];
  static const localRedisPort = '12758';
  static String redisPort = envRedisPort ?? localRedisPort;

  static final envRedisHostname = Platform.environment['REDIS_HOSTNAME'];
  static const localRedisHostname =
      'redis-12758.c261.us-east-1-4.ec2.cloud.redislabs.com';
  static String redisHostname = envRedisHostname ?? localRedisHostname;

  static final envRedisPassword = Platform.environment['REDIS_PASSWORD'];
  static const localRedisPassword = '3ZaHRetFEWnSeVOlaj31njpYb93FpiVA';
  static String redisPassword = envRedisPassword ?? localRedisPassword;

  //JWT AuthValues
  static const secret = '95EEC74B0E486EF';
  static const issuer = 'danielmgawi.com';
  static const subject = 'P23';
  static const maxAge = '5';
  static const typ = 'authnresponse';
  //Values
  static const rewardValue = '50.00';
  static const minTransactionAmount = '10.00';
  static const difficulty = '0000';
  static const newAccountBalance = '1000.00';
}
