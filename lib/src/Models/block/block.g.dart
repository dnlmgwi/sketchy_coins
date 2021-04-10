// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'block.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BlockAdapter extends TypeAdapter<Block> {
  @override
  final int typeId = 1;

  @override
  Block read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Block(
      index: fields[4] as int,
      timestamp: fields[5] as int,
      proof: fields[7] as int,
      prevHash: fields[8] as String,
      transactions: (fields[6] as List).cast<Transaction>(),
    );
  }

  @override
  void write(BinaryWriter writer, Block obj) {
    writer
      ..writeByte(5)
      ..writeByte(4)
      ..write(obj.index)
      ..writeByte(5)
      ..write(obj.timestamp)
      ..writeByte(6)
      ..write(obj.transactions)
      ..writeByte(7)
      ..write(obj.proof)
      ..writeByte(8)
      ..write(obj.prevHash);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BlockAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

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
