class EnvValues {
  //Server Variables
  final port = 8080;
  final hostName = '0.0.0.0';
  final systemAddress = 'P23 Admin';

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
