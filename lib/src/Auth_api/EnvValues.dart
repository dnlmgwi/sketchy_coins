class EnvValues {
  //Server Variables
  final port = 8080;
  final hostName = '0.0.0.0';
  final jwt_auth_sharedSecret = 'e4PNft2h';
  final systemAddress =
      '6022634d1f0bfc7777112ee9bddd3e81085c36c8c62433eecc5467dd299f69b1';

  //AuthValues
  final issuer = 'Daniel Mgawi';
  final subject = 'P23';
  static const maxAge = 5;
  final typ = 'authnresponse';

  //KKoin Value
  final rewardValue = 100.0;
  final minTransactionAmount = 10.00;
  final difficulty = '0000';
  final newAccountBalance = 1000.00;
}

EnvValues enviromentVariables = EnvValues();
