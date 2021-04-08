import 'package:sketchy_coins/src/Blockchain_api/transaction.dart';

class Account {
  final String address;
  final String status;
  final double balance;
  final List<Transaction> transactions;

  Account({
    this.address,
    this.status,
    this.balance,
    this.transactions,
  });

  Map<String, dynamic> toJson() {
    // keys must be ordered for consistent hashing
    var block = <String, dynamic>{};

    block['address'] = address;
    block['status'] = status;
    block['balance'] = balance;
    //Sort in acending order of time.
    block['transactions'] = transactions.map((t) => t.toJson()).toList();

    return block;
  }

  Account.fromJson(Map<String, dynamic> json)
      : address = json['address'],
        status = json['status'],
        balance = json['balance'],
        transactions = json['transactions'] as List<Transaction>;
}
