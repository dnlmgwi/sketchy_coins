// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AccountAdapter extends TypeAdapter<Account> {
  @override
  final int typeId = 4;

  @override
  Account read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Account(
      address: fields[20] as String,
      status: fields[21] as String,
      balance: fields[22] as double,
      transactions: (fields[23] as List?)?.cast<Transaction>(),
    );
  }

  @override
  void write(BinaryWriter writer, Account obj) {
    writer
      ..writeByte(4)
      ..writeByte(20)
      ..write(obj.address)
      ..writeByte(21)
      ..write(obj.status)
      ..writeByte(22)
      ..write(obj.balance)
      ..writeByte(23)
      ..write(obj.transactions);
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