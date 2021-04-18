import 'package:sketchy_coins/packages.dart';
part 'jwtModel.g.dart';

@HiveType(typeId: 4)
@JsonSerializable(explicitToJson: true)
class JWTModel extends HiveObject {
  @HiveField(1)
  String jwt;

  JWTModel({
    required this.jwt,
  });

  factory JWTModel.fromJson(Map<String, dynamic> json) =>
      _$JWTModelFromJson(json);

  Map<String, dynamic> toJson() => _$JWTModelToJson(this);
}
