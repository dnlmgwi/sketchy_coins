import 'package:sketchy_coins/packages.dart';
part 'location.g.dart';

@HiveType(typeId: 5)
@JsonSerializable(explicitToJson: true)
class Location extends HiveObject {
  @HiveField(1)
  int address;

  @HiveField(2)
  int lat;

  @HiveField(3)
  int lng;

  Location({
    required this.address,
    required this.lat,
    required this.lng,
  });

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);
  Map<String, dynamic> toJson() => _$LocationToJson(this);
}
