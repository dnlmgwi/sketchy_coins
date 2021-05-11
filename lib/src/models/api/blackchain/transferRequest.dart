import 'package:sketchy_coins/packages.dart';

part 'transferRequest.g.dart';

/// An annotation for the code generator to know that this class needs the
/// JSON serialization logic to be generated.
@JsonSerializable(explicitToJson: true)
class TransferRequest {
  late String? id;

  late int? amount;

  String? get getId => id;

  set setId(String? id) => this.id = id;

  int? get getAmount => amount;

  set setAmount(int? amount) => this.amount = amount;

  TransferRequest({
    required this.id,
    required this.amount,
  });

  factory TransferRequest.fromJson(Map<String, dynamic> json) =>
      _$TransferRequestFromJson(json);

  Map<String, dynamic> toJson() => _$TransferRequestToJson(this);
}
