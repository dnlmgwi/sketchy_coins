class AccountNotFoundException implements Exception {
  ///This Exception is thrown when the account cannot be Found in the DB
  late String _message;

  AccountNotFoundException([String message = 'Account Not Found']) {
    _message = message;
  }

  @override
  String toString() {
    return _message;
  }
}

class TransIDNotFoundException implements Exception {
  ///This Exception is thrown when the account cannot be Found in the DB
  late String _message;

  TransIDNotFoundException([String message = 'Invalid TransID']) {
    _message = message;
  }

  @override
  String toString() {
    return _message;
  }
}

class TransIDClaimedException implements Exception {
  ///This Exception is thrown when the account cannot be Found in the DB
  late String _message;

  TransIDClaimedException(
      [String message = 'TransID has already been claimed']) {
    _message = message;
  }

  @override
  String toString() {
    return _message;
  }
}

class AccountDuplicationFoundException implements Exception {
  ///This Exception is thrown when there is an excisting account in the DB
  late String _message;

  AccountDuplicationFoundException(
      [String message = 'Please, login Instead.']) {
    _message = message;
  }

  @override
  String toString() {
    return _message;
  }
}

class RegisteredCredentialsException implements Exception {
  ///This Exception is thrown when there is an excisting account in the DB
  late String _message;

  RegisteredCredentialsException(
      [String message = 'These Details are Registered, Login instead']) {
    _message = message;
  }

  @override
  String toString() {
    return _message;
  }
}

class IncorrectInputException implements Exception {
  ///This Exception is thrown when there is an excisting account in the DB
  late String _message;

  IncorrectInputException([String message = 'Incorrect User id or Password']) {
    _message = message;
  }

  @override
  String toString() {
    return _message;
  }
}

class InvalidInputException implements Exception {
  ///This Exception is thrown when there is an invalid Input Entered in the DB
  late String _message;

  InvalidInputException([String message = 'Please provide a valid Input']) {
    _message = message;
  }

  @override
  String toString() {
    return _message;
  }
}

class InvalidUserIDException implements Exception {
  ///This Exception is thrown when there is an invalid Input Entered in the DB
  late String _message;

  InvalidUserIDException([String message = 'Please provide a valid User ID']) {
    _message = message;
  }

  @override
  String toString() {
    return _message;
  }
}

class InvalidAmountException implements Exception {
  ///This Exception is thrown when there is an invalid Input Entered in the DB
  late String _message;

  InvalidAmountException([String message = 'Please provide a valid Amount']) {
    _message = message;
  }

  @override
  String toString() {
    return _message;
  }
}

class InsufficientFundsException implements Exception {
  ///This Exception is thrown when there is Insufficient Funds in the account
  late String _message;

  InsufficientFundsException([String message = 'Insufficient funds']) {
    _message = message;
  }

  @override
  String toString() {
    return _message;
  }
}

class PendingTransactionException implements Exception {
  ///This Exception is thrown when the account has a pending transaction
  late String _message;

  PendingTransactionException(
      [String message = 'Please await your pending transaction']) {
    _message = message;
  }

  @override
  String toString() {
    return _message;
  }
}

class SelfTransferException implements Exception {
  ///This Exception is thrown when the account has a pending transaction
  late String _message;

  SelfTransferException(
      [String message =
          'Please provided a different accounts to preform a transfer']) {
    _message = message;
  }

  @override
  String toString() {
    return _message;
  }
}

class NoPendingTransactionException implements Exception {
  ///This Exception is thrown when there is an excisting account in the DB
  late String _message;

  NoPendingTransactionException([String message = 'Nothing to Mine']) {
    _message = message;
  }

  @override
  String toString() {
    return _message;
  }
}

class UnauthorisedException implements Exception {
  ///This Exception is thrown when there is an excisting account in the DB
  late String _message;

  UnauthorisedException(
      [String message = 'Not authorised to perform this request']) {
    _message = message;
  }

  @override
  String toString() {
    return _message;
  }
}
