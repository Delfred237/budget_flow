import 'package:budget_flow/core/database/app_database.dart';

class CategoryPercentage {
  final Category category;
  final double totalAmount;
  final double percentage;

  CategoryPercentage({
    required this.category,
    required this.totalAmount,
    required this.percentage,
  });
}
