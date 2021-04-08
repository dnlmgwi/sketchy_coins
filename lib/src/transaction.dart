class Transaction {
  String sender;
  String recipient;
  double amount;
  int timestamp;
  int proof;
  String prevHash;

  Transaction({
    this.sender,
    this.recipient,
    this.amount,
    this.timestamp,
