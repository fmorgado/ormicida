part of ormicida.orm.schema;

class IsInt extends IsDynamic {
  final int min;
  final int max;
  
  const IsInt({this.min, this.max, bool nullable: false}): super(nullable);
  
  Map _getExceptionArgument() {
    final result = {};
    if (min != null) result['min'] = min;
    if (max != null) result['max'] = max;
    return result;
  }
  
  Object normalizeAndValidate(value) {
    if (value is! int) {
      throw new SchemaException(SchemaException.NOT_AN_INTEGER);
    } else if (min != null && value < min) {
      throw new SchemaException(SchemaException.NOT_HIGHER_EQUAL, _getExceptionArgument());
    } else if (max != null && value > max) {
      throw new SchemaException(SchemaException.NOT_LOWER_EQUAL, _getExceptionArgument());
    }
    return value;
  }
}
