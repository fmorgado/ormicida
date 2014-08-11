library test.ormicida._utils;

import 'package:unittest/unittest.dart';

class IsDoubleValue extends Matcher {
  final double value;
  final num percentage;
  
  const IsDoubleValue(this.value, {this.percentage: 1});
  
  bool matches(obj, Map matchState) {
    if (obj is! num) {
      return false;
    }
    if (obj.isFinite) {
      if (value.isFinite) {
        if (obj.isNegative != obj.isNegative)
          return false;
        final delta = (obj - value).abs();
        final limit = (obj * (percentage / 100)).abs();
        return delta <= limit;
      } else {
        return false;
      } 
    } else {
      if (obj.isNaN)
        return value.isNaN;
      else if (obj == double.INFINITY)
        return value == double.INFINITY;
      else if (obj == double.NEGATIVE_INFINITY)
        return value == double.NEGATIVE_INFINITY;
      return false;
    }
  }
  Description describe(Description description) => description.add('is NaN');
}
