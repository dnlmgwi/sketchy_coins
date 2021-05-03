import 'package:sketchy_coins/packages.dart';
part 'tokenPair.g.dart';

@JsonSerializable(explicitToJson: true)
class TokenPair extends HiveObject {
  final String token;

  final String refreshToken;

  TokenPair({
    required this.token,
    required this.refreshToken,
  });

  factory TokenPair.fromJson(Map<String, dynamic> json) =>
      _$TokenPairFromJson(json);

  Map<String, dynamic> toJson() => _$TokenPairToJson(this);
}
