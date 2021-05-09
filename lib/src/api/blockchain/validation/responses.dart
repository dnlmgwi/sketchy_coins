import 'package:sketchy_coins/packages.dart';

class BlockChainApiResponses {
  //No Recipient Provided
  static String recipientError() {
    return json.encode({
      'data': {
        'message': 'Please Provide Recipient id',
      }
    });
  }

  //No Amount Provided
  static String amountError() {
    return json.encode({
      'data': {
        'message':
            'Please include valid amount Greater Than P${Env.minTransactionAmount}',
      }
    });
  }
}
