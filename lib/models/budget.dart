// models/budget.dart
import 'package:hive/hive.dart';
part 'budget.g.dart';

@HiveType(typeId: 2)
class Budget extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String categoryId;

  @HiveField(2)
  late double limit;

  @HiveField(3)
  late String period; // "Weekly", "Monthly", "Annual"

  Budget({
    required this.id,
    required this.categoryId,
    required this.limit,
    required this.period,
  });
}