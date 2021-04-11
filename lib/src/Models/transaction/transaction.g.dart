// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransactionAdapter extends TypeAdapter<Transaction> {
  @override
  final int typeId = 3;

  @override
  Transaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Transaction(
      sender: fields[15] as String,
      recipient: fields[16] as String,
      amount: fields[17] as double,
      timestamp: fields[18] as int,
      transID: fields[19] as String,
      proof: fields[20] as int,
      prevHash: fields[21] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Transaction obj) {
    writer
      ..writeByte(7)
      ..writeByte(15)
      ..write(obj.sender)
      ..writeByte(16)
      ..write(obj.recipient)
      ..writeByte(17)
      ..write(obj.amount)
      ..writeByte(18)
      ..write(obj.timestamp)
      ..writeByte(19)
      ..write(obj.transID)
      ..writeByte(20)
      ..write(obj.proof)
      ..writeByte(21)
      ..write(obj.prevHash);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

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
