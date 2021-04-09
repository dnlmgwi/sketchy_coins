// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Transaction _$TransactionFromJson(Map<String, dynamic> json) {
  return Transaction(
    sender: json['sender'] as String,
    recipient: json['recipient'] as String,
    amount: (json['amount'] as num).toDouble(),
    timestamp: json['timestamp'] as int,
    transID: json['transID'] as String,
    proof: json['proof'] as int,
    prevHash: json['prevHash'] as String,
  );
}

Map<String, dynamic> _$TransactionToJson(Transaction instance) =>
    <String, dynamic>{
      'sender': instance.sender,
      'recipient': instance.recipient,
      'amount': instance.amount,
      'timestamp': instance.timestamp,
      'transID': instance.transID,
      'proof': instance.proof,
      'prevHash': instance.prevHash,
    };
