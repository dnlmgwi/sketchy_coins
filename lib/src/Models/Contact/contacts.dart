import 'package:isar/isar.dart';

@Collection()
class Contact {
  @Id()
  int? id;
  
  String? name;
}
