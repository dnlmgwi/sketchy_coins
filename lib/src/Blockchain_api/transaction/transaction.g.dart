// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Transaction _$TransactionFromJson(Map<String, dynamic> json) {
  return Transaction(
    json['sender'] as String?,
    json['recipient'] as String?,
    (json['amount'] as num?)?.toDouble(),
    json['timestamp'] as int?,
  )
    ..proof = json['proof'] as int?
    ..prevHash = json['prevHash'] as String?;
}

Map<String, dynamic> _$TransactionToJson(Transaction instance) =>
    <String, dynamic>{
      'sender': instance.sender,
      'recipient': instance.recipient,
      'amount': instance.amount,
      'timestamp': instance.timestamp,
      'proof': instance.proof,
      'prevHash': instance.prevHash,
    };
