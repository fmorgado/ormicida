part of ormicida.orm.schema;

class IsDateTime extends IsDynamic {
  final DateTime after;
  final DateTime before;
  final bool     hasTime;
  
  const IsDateTime({this.after, this.before,
        this.hasTime: false, bool nullable: false})
    : super(nullable);
  
  Map _getBoundsArgument() {
    final result = {};
    if (after != null)  result['after'] = after;
    if (before != null) result['before'] = before;
    return result;
  }
  
  Object normalizeAndValidate(value) {
    if (value is String) {
      try {
        value = DateTime.parse(value);
      } catch (e) {
        throw new SchemaException(SchemaException.INVALID_DATE_FORMAT);
      }
    } else if (value is int) {
      value = new DateTime.fromMillisecondsSinceEpoch(value);
    }
    
    if (value is! DateTime) {
      throw new SchemaException(SchemaException.NOT_A_DATE);
    } else if (after != null && after.isAfter(value)) {
      throw new SchemaException(SchemaException.DATE_OUT_OF_BOUNDS, _getBoundsArgument());
    } else if (before != null && before.isBefore(value)) {
      throw new SchemaException(SchemaException.DATE_OUT_OF_BOUNDS, _getBoundsArgument());
    }
    return value;
  }
}
