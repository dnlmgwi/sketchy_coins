import 'package:sketchy_coins/packages.dart';

class AuthService {
  final _accountList = Hive.box<Account>('accounts');

  Account findAccount(
      {required Box<Account> accounts, required String address}) {
    return accounts.values.firstWhere((element) => element.address == address,
        orElse: () => throw AccountNotFoundException());
  }

  Account findDuplicateAccount(
      {required Box<Account> accounts, required String email}) {
    return accounts.values.firstWhere(
      (element) => element.email == email,
      orElse: () => throw AccountDuplicationException(),
    );
  }

  bool validateAccount({
    required String email,
  }) {
    var duplicateAccount = false;
    try {
      findDuplicateAccount(accounts: _accountList, email: email);
    } catch (e) {
      // If account is found return true and thrown error is
      return duplicateAccount = true;
    }
    return duplicateAccount;
  }

  void register({
    required String password,
    required String email,
    required String phoneNumber,
  }) {
    final salt = generateSalt();
    final hashpassword = hashPassword(password: password, salt: salt);

    if (validateAccount(email: email)) {
      _accountList.add(
        Account(
          email: email, //TODO: dateCreated
          address: email, //TODO: Revisit address algo
          phoneNumber: phoneNumber, //TODO: Hash PhoneNumber?
          password: hashpassword,
          salt: salt,
          status: 'normal',
          balance: double.parse(Env.newAccountBalance),
          joinedDate: DateTime.now().millisecondsSinceEpoch
        ),
      );
    } else {
      throw AccountDuplicationException();
    }
  }

  Future<TokenPair> login({
    required String password,
    required String address,
    required TokenService tokenService,
  }) async {
    Account user;
    TokenPair tokenPair;

    try {
      user = findAccount(
        accounts: _accountList,
        address: address,
      );

      final hashpassword = hashPassword(
        password: password,
        salt: user.salt,
      );

      if (hashpassword != user.password) {
        throw IncorrectInputException();
      }

      tokenPair = await tokenService.createTokenPair(userId: user.address);
    } catch (e) {
      rethrow;
    }

    return tokenPair;
  }

  String identityHash(String data) {
    var key = utf8.encode('psalms23'); //TODO: improve address hashing
    var bytes = utf8.encode(data);

    var hmacSha256 = Hmac(sha256, key); // HMAC-SHA256
    var digest = hmacSha256.convert(bytes);

    return digest.toString();
  }

  Box<Account> get accountList {
    return _accountList;
  }
}
