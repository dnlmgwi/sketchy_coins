import 'package:sketchy_coins/packages.dart';
part 'location.g.dart';

@JsonSerializable(explicitToJson: true)
class Location {
  int address;

  int lat;

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
