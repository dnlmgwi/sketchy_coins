// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'block.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Block _$BlockFromJson(Map<String, dynamic> json) {
  return Block(
    index: json['index'] as int,
    timestamp: json['timestamp'] as int,
    proof: json['proof'] as int,
    prevHash: json['prevHash'] as String,
    transactions: (json['transactions'] as List<dynamic>)
        .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$BlockToJson(Block instance) => <String, dynamic>{
      'index': instance.index,
      'timestamp': instance.timestamp,
      'transactions': instance.transactions.map((e) => e.toJson()).toList(),
      'proof': instance.proof,
      'prevHash': instance.prevHash,
    };
