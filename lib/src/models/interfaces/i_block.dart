import 'package:sketchy_coins/packages.dart';

abstract class IBlock {
  late int? index;

  late int timestamp;

  late List? blockTransactions;

  late int proof;

  late String? prevHash;

  Map<String, dynamic> toJson();
}
