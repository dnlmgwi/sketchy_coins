import 'package:sketchy_coins/packages.dart';

class AuthApiValidation {
  /// Is Valid PhoneNumber Provided
  static bool phoneNumberCheck(phoneNumber) {
    var isphoneNumberRegEx =
        RegExp(r'^[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}$');
    return phoneNumber == null ||
        phoneNumber == '' ||
        !isphoneNumberRegEx.hasMatch(phoneNumber);
  }

  //Is Strong Password Provided
  static bool passwordCheck(password) {
    //Strong Password
    ///               # assert that
    /// (?=^.{8,}$)    # there are at least 8 characters
    /// (              # and
    /// (?=.*\d)       # there is at least a digit
    /// |              # or
    /// (?=.*\W+)      # there is one or more "non word" characters (\W is equivalent to [^a-zA-Z0-9_])
    /// )              # and
    /// (?![.\n])      # there is no . or newline and
    /// (?=.*[A-Z])    # there is at least an upper case letter and
    /// (?=.*[a-z]).*$ # there is at least a lower case letter
    /// .*$            # in a string of any characters

    var isPasswordRegExp = RegExp(
        r'(?=^.{8,}$)(?=.*\d)(?=.*[!@#$%^&*]+)(?![.\n])(?=.*[A-Z])(?=.*[a-z]).*$');
    return password == null ||
        password == '' ||
        !isPasswordRegExp.hasMatch(password);
  }

  /// Is Valid Email Provided
  static bool emailCheck(email) => email == null || email == '' || !isEmail(email);
}
