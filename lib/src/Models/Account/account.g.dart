// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Account _$AccountFromJson(Map<String, dynamic> json) {
  return Account(
    address: json['address'] as String,
    status: json['status'] as String,
    balance: (json['balance'] as num).toDouble(),
    transactions: (json['transactions'] as List<dynamic>?)
        ?.map((e) => Transaction.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$AccountToJson(Account instance) => <String, dynamic>{
      'address': instance.address,
      'status': instance.status,
      'balance': instance.balance,
      'transactions': instance.transactions?.map((e) => e.toJson()).toList(),
    };
