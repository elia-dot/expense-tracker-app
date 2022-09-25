import 'package:flutter/material.dart';

class CategoryChartData {
  final String _category;
  final double _amount;
  final Color _color;
  CategoryChartData(this._category, this._amount, this._color);

  @override
  String toString() {
    return 'ChartData{category: $category, amount: $amount, color: $color}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CategoryChartData &&
        other.category == category &&
        other.amount == amount &&
        other.color == color;
  }

  String get category {
    return _category;
  }

  double get amount {
    return _amount;
  }

  Color get color {
    return _color;
  }

  @override
  int get hashCode => category.hashCode ^ amount.hashCode;
}
