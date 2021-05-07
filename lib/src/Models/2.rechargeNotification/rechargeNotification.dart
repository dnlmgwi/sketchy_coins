import 'package:sketchy_coins/packages.dart';
part 'rechargeNotification.g.dart';

@HiveType(typeId: 1)
@JsonSerializable()
class RechargeNotification extends HiveObject {
  @HiveField(1)
  String transID;

  @HiveField(2)
  String phoneNumber;

  @HiveField(3)
  String amount;

  @HiveField(4)
  int timestamp;

  RechargeNotification({
    required this.phoneNumber,
    required this.amount,
    required this.transID,
    required this.timestamp
  });

  factory RechargeNotification.fromJson(Map<String, dynamic> json) =>
      _$RechargeNotificationFromJson(json);
  Map<String, dynamic> toJson() => _$RechargeNotificationToJson(this);
}
