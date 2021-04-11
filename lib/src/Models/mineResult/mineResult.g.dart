// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mineResult.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MineResultAdapter extends TypeAdapter<MineResult> {
  @override
  final int typeId = 2;

  @override
  MineResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MineResult(
      message: fields[1] as String,
      validBlock: fields[3] as bool?,
      blockIndex: fields[2] as int,
      transactions: (fields[4] as List).cast<Transaction>(),
      proof: fields[5] as int,
      prevHash: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MineResult obj) {
    writer
      ..writeByte(6)
      ..writeByte(1)
      ..write(obj.message)
      ..writeByte(2)
      ..write(obj.blockIndex)
      ..writeByte(3)
      ..write(obj.validBlock)
      ..writeByte(4)
      ..write(obj.transactions)
      ..writeByte(5)
      ..write(obj.proof)
      ..writeByte(6)
      ..write(obj.prevHash);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MineResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MineResult _$MineResultFromJson(Map<String, dynamic> json) {
  return MineResult(
    message: json['message'] as String,
    validBlock: json['validBlock'] as bool?,
    blockIndex: json['blockIndex'] as int,
    transactions: (json['transactions'] as List<dynamic>)
        .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
        .toList(),
    proof: json['proof'] as int,
    prevHash: json['prevHash'] as String,
  );
}

Map<String, dynamic> _$MineResultToJson(MineResult instance) =>
    <String, dynamic>{
      'message': instance.message,
      'blockIndex': instance.blockIndex,
      'validBlock': instance.validBlock,
      'transactions': instance.transactions.map((e) => e.toJson()).toList(),
      'proof': instance.proof,
      'prevHash': instance.prevHash,
    };
