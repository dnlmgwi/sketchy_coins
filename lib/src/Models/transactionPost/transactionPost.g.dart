// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transactionPost.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionPost _$TransactionPostFromJson(Map<String, dynamic> json) {
  return TransactionPost(
    sender: json['sender'] as String,
    recipient: json['recipient'] as String,
    amount: (json['amount'] as num).toDouble(),
  );
}

Map<String, dynamic> _$TransactionPostToJson(TransactionPost instance) =>
    <String, dynamic>{
      'sender': instance.sender,
      'recipient': instance.recipient,
      'amount': instance.amount,
    };
