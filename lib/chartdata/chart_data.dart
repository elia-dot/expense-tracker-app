class ChartData {
  final String xAxis;
  final double yAxis;
  ChartData(this.xAxis, this.yAxis);

  @override
  String toString() {
    return 'ChartData{y: $x, x: $y}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChartData && other.y == y && other.x == x;
  }

  double get y {
    return yAxis;
  }

  String get x {
    return xAxis;
  }

  @override 
  int get hashCode => y.hashCode ^ x.hashCode;
}
