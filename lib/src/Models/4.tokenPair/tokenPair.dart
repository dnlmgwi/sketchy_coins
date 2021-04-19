import 'package:sketchy_coins/packages.dart';
part 'tokenPair.g.dart';

@HiveType(typeId: 4)
@JsonSerializable(explicitToJson: true)
class TokenPair extends HiveObject {
  @HiveField(1)
  final String token;

  @HiveField(2)
  final String refreshToken;

  TokenPair({
    required this.token,
    required this.refreshToken,
  });

  factory TokenPair.fromJson(Map<String, dynamic> json) =>
      _$TokenPairFromJson(json);

  Map<String, dynamic> toJson() => _$TokenPairToJson(this);
}
