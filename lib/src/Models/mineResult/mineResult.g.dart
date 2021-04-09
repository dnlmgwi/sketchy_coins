// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mineResult.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MineResult _$MineResultFromJson(Map<String, dynamic> json) {
  return MineResult(
    message: json['message'] as String?,
    validBlock: json['validBlock'] as bool?,
    blockIndex: json['blockIndex'] as int?,
    transactions: (json['transactions'] as List<dynamic>?)
        ?.map((e) => Transaction.fromJson(e as Map<String, dynamic>))
        .toList(),
    proof: json['proof'] as int?,
    prevHash: json['prevHash'] as String?,
  );
}

Map<String, dynamic> _$MineResultToJson(MineResult instance) =>
    <String, dynamic>{
      'message': instance.message,
      'blockIndex': instance.blockIndex,
      'validBlock': instance.validBlock,
      'transactions': instance.transactions?.map((e) => e.toJson()).toList(),
      'proof': instance.proof,
      'prevHash': instance.prevHash,
    };
