import 'package:crdt/crdt.dart';
import 'package:sketchy_coins/packages.dart';

class OfflineAccountsService {
  var accountService = AccountService();
  final hlc = Hlc.now(Env.hostName);

  var crdt = MapCrdt(Env.hostName);

  // accountService.accountList.values.last.toJson()

  Map sendToRemote() {
    return {
      'hlc': '$hlc',
      'value': accountService.accountList.values.last.toJson()
    };
  }

  void mergeRemoteAccounts(String json) {
    crdt.mergeJson(json);
    print(crdt);
  }
}
