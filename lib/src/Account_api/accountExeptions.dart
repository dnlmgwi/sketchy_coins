class AccountNotFoundException implements Exception {
  late String _message;

  AccountNotFoundException([String message = 'Account Not Found']) {
    _message = message;
  }

  @override
  String toString() {
    return _message;
  }
}

class AccountDuplicationException implements Exception {
  late String _message;

  AccountDuplicationException([String message = 'Duplicate Account Found']) {
    _message = message;
  }

  @override
  String toString() {
    return _message;
  }
}

class InvalidInputException implements Exception {
  late String _message;

  InvalidInputException([String message = 'Please provide a valid Input']) {
    _message = message;
  }

  @override
  String toString() {
    return _message;
  }
}

class InsufficientFundsException implements Exception {
  late String _message;

  InsufficientFundsException([String message = 'Insufficient funds']) {
    _message = message;
  }

  @override
  String toString() {
    return _message;
  }
}
