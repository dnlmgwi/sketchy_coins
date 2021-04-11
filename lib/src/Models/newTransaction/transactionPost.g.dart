// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transactionPost.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransactionPostAdapter extends TypeAdapter<TransactionPost> {
  @override
  final int typeId = 2;

  @override
  TransactionPost read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TransactionPost(
      sender: fields[12] as String,
      recipient: fields[13] as String,
      amount: fields[14] as double,
    );
  }

  @override
  void write(BinaryWriter writer, TransactionPost obj) {
    writer
      ..writeByte(3)
      ..writeByte(12)
      ..write(obj.sender)
      ..writeByte(13)
      ..write(obj.recipient)
      ..writeByte(14)
      ..write(obj.amount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionPostAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

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
