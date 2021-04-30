class InvalidPasswordException implements Exception {
  ///This Exception is thrown when there is an invalid Input Entered in the DB
  late String _message;

  InvalidPasswordException([String message = 'Please provide a valid Input']) {
    _message = message;
  }

  @override
  String toString() {
    return _message;
  }
}

class InvalidPhoneNumberException implements Exception {
  ///This Exception is thrown when there is an invalid Input Entered in the DB
  late String _message;

  InvalidPhoneNumberException([String message = 'Please provide a valid Input']) {
    _message = message;
  }

  @override
  String toString() {
    return _message;
  }
}
