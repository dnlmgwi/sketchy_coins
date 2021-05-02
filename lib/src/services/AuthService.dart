import 'package:sketchy_coins/packages.dart';

class AuthService {
  DatabaseService databaseService;

  AuthService({
    required this.databaseService,
  });

  final _accountList = Hive.box<Account>('accounts');

  Future fetchUsers() async {
    var response = await getUsers();
    return response;
  }

  Future getUsers() async {
    try {
      final response =
          await databaseService.client.from('countries').select().execute();
      if (response.error != null) {
        throw response.error!;
      }
      return response.data;
    } on PostgrestError catch (e) {
      print(e.code);
      print(e.message);
      rethrow;
    }
  }

  Account findAccount(
      {required Box<Account> accounts, required String address}) {
    return accounts.values.firstWhere((element) => element.address == address,
        orElse: () => throw AccountNotFoundException());
  }

  Account findDuplicateAccountCredentials(
      {required Box<Account> accounts,
      required String email,
      required String phoneNumber}) {
    return accounts.values.firstWhere(
      (element) => element.email == email,
      orElse: () => throw RegisteredCredentialsException(),
    );
  }

  bool isNotDuplicatedAccount({
    required String email,
    required String phoneNumber,
  }) {
    var duplicateAccount = false;
    try {
      findDuplicateAccountCredentials(
          accounts: _accountList, email: email, phoneNumber: phoneNumber);
    } catch (e) {
      // If account is found return Duplicate account is true and thrown error message.
      duplicateAccount = true;
      rethrow;
    }
    return duplicateAccount;
  }

  void register({
    required String password,
    required String email,
    required String phoneNumber,
  }) {
    final salt = generateSalt();

    final hashpassword = hashPassword(
      password: password,
      salt: salt,
    );

    final address = userAddressAlgo(
      phoneNumber: phoneNumber,
    );

    try {
      if (isNotDuplicatedAccount(email: email, phoneNumber: phoneNumber)) {
        _accountList.add(
          Account(
            email: email,
            address: address, //TODO: Revisit address algo
            phoneNumber: phoneNumber,
            password: hashpassword,
            salt: salt,
            status: 'normal',
            balance: double.parse(Env.newAccountBalance),
            joinedDate: DateTime.now().millisecondsSinceEpoch,
          ),
        );
      } else {
        throw AccountDuplicationFoundException();
      }
    } catch (e) {
      rethrow;
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

  Box<Account> get accountList {
    return _accountList;
  }

  Future get accountdbList async {
    return await fetchUsers();
  }
}
