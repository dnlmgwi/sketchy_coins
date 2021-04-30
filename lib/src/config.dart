import 'package:envify/envify.dart';
part 'config.g.dart';

@Envify()
abstract class Env {
  //Server Side
  static const port = _Env.port;
  static const hostName = _Env.hostName;
  //Reward System Address
  static const systemAddress = _Env.systemAddress;
  //Database
  // static const postgresqlUrl = _Env.postgresqlUrl;
  //Cache
  static const redisPort = _Env.redisPort;
  static const redisHostname = _Env.redisHostname;
  static const redisPassword = _Env.redisPassword;
  //JWT AuthValues
  static const secret = _Env.secret;
  static const issuer = _Env.issuer;
  static const subject = _Env.subject;
  static const maxAge = _Env.maxAge;
  static const typ = _Env.typ;
  //Value
  static const rewardValue = _Env.rewardValue;
  static const minTransactionAmount = _Env.minTransactionAmount;
  static const difficulty = _Env.difficulty;
  static const newAccountBalance = _Env.newAccountBalance;
}
