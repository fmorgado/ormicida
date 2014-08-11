part of ormicida.orm.schema;

class IsNum extends IsDynamic {
  final num   min;
  final num   max;
  final num   minEx;
  final num   maxEx;
  final bool  allowNaN;
  final bool  allowInf;
  final bool  allowNegInf;

  const IsNum({this.min, this.max, this.minEx, this.maxEx, this.allowNaN: false,
          this.allowInf: false, this.allowNegInf: false, bool nullable: false})
      : super(nullable);
  
  Map _getExceptionArgument() {
    final result = {};
    if (min != null)   result['min'] = min;
    if (max != null)   result['max'] = max;
    if (minEx != null) result['minEx'] = minEx;
    if (maxEx != null) result['maxEx'] = maxEx;
    return result;
  }
  
  Object normalizeAndValidate(value) {
    if (value is! num) {
      throw new SchemaException(SchemaException.NOT_A_NUMBER);
    } else if (value.isNaN) {
      if (! allowNaN) {
        throw new SchemaException(SchemaException.NAN_NOT_ALLOWED);
      }
      return double.NAN;
    } else if (value == double.INFINITY) {
      if (! allowInf) {
        throw new SchemaException(SchemaException.INF_NOT_ALLOWED);
      }
      return double.INFINITY;
    } else if (value == double.NEGATIVE_INFINITY) {
      if (! allowNegInf) {
        throw new SchemaException(SchemaException.NEG_INF_NOT_ALLOWED);
      }
      return double.NEGATIVE_INFINITY;
    } else if (min != null && value < min) {
      throw new SchemaException(SchemaException.NOT_HIGHER_EQUAL, _getExceptionArgument());
    } else if (max != null && value > max) {
      throw new SchemaException(SchemaException.NOT_LOWER_EQUAL, _getExceptionArgument());
    } else if (minEx != null && value <= minEx) {
      throw new SchemaException(SchemaException.NOT_HIGHER_THAN, _getExceptionArgument());
    } else if (maxEx != null && value >= maxEx) {
      throw new SchemaException(SchemaException.NOT_LOWER_THAN, _getExceptionArgument());
    }
    return value;
  }
}
