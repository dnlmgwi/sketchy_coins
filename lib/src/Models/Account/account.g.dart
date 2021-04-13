// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AccountAdapter extends TypeAdapter<Account> {
  @override
  final int typeId = 0;

  @override
  Account read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Account(
      address: fields[1] as String,
      status: fields[2] as String,
      balance: fields[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Account obj) {
    writer
      ..writeByte(3)
      ..writeByte(1)
      ..write(obj.address)
      ..writeByte(2)
      ..write(obj.status)
      ..writeByte(3)
      ..write(obj.balance);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Account _$AccountFromJson(Map<String, dynamic> json) {
  return Account(
    address: json['address'] as String,
    status: json['status'] as String,
    balance: (json['balance'] as num).toDouble(),
  );
}

Map<String, dynamic> _$AccountToJson(Account instance) => <String, dynamic>{
      'address': instance.address,
      'status': instance.status,
      'balance': instance.balance,
    };
