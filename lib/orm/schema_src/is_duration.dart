part of ormicida.orm.schema;

class IsDuration extends IsDynamic {
  final Duration min;
  final Duration max;
  
  const IsDuration({this.min, this.max, bool nullable: false}): super(nullable);
  
  Map _getExceptionArgument() {
    final result = {};
    if (min != null) result['min'] = min;
    if (max != null) result['max'] = max;
    return result;
  }
  
  Object normalizeAndValidate(value) {
    if (value is int) {
      value = new Duration(microseconds: value);
    } else if (value is! Duration) {
      throw new SchemaException(SchemaException.NOT_A_DURATION);
    }
    
    if (min != null && value < min) {
      throw new SchemaException(SchemaException.NOT_HIGHER_EQUAL, _getExceptionArgument());
    } else if (max != null && value > max) {
      throw new SchemaException(SchemaException.NOT_LOWER_EQUAL, _getExceptionArgument());
    }
    return value;
  }
}
