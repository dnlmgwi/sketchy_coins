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
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'sender': sender,
      'recipient': recipient,
      'amount': amount,
      'timeStamp': timestamp,
      'proof': proof,
      'prevHash': prevHash,
    };
  }
}
