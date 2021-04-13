class EnvValues {
  //Server Variables
  final port = 3000;
  final hostName = '0.0.0.0';
  final jwt_auth_sharedSecret = 'e4PNft2h';

  //AuthValues
  final issuer = 'King Of The Grid Esports';
  final subject = 'kkoins';
  static const maxAge = 5;
  final typ = 'authnresponse';

  //KKoin Value
  final rewardValue = 1.0;
  final minTransactionAmount = 10.00;
  final difficulty = '0000';
}

EnvValues enviromentVariables = EnvValues();
