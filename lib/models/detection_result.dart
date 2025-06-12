import 'package:hive/hive.dart';

part 'detection_result.g.dart';

@HiveType(typeId: 0)
class DetectionResult extends HiveObject {
  @HiveField(0)
  String label;

  @HiveField(1)
  String description;

  @HiveField(2)
  String imagePath;

  @HiveField(3)
  DateTime date;

  DetectionResult({
    required this.label,
    required this.description,
    required this.imagePath,
    required this.date,
  });
}
