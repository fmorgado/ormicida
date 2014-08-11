part of ormicida.orm.schema;

class IsList extends Schema {
  final Schema  schema;
  final int     minLen;
  final int     maxLen;
  
  const IsList({this.schema: const IsDynamic(true),
                this.minLen, this.maxLen, bool nullable: false})
              : super(nullable);
  
  Map getLengthExceptionArgument() {
    final result = {};
    if (minLen != null) result['min'] = minLen;
    if (maxLen != null) result['max'] = maxLen;
    return result;
  }
  
  /*
  void validate(value) {
    if (value == null) {
      if (! nullable)
        throw new SchemaException(SchemaException.NOT_NULLABLE);
    } else if (value is! List) {
      throw new SchemaException(SchemaException.NOT_A_LIST);
    } else if (minLen != null && value.length < minLen) {
      throw new SchemaException(SchemaException.LIST_TOO_SHORT, getLengthExceptionArgument());
    } else if (maxLen != null && value.length > maxLen) {
      throw new SchemaException(SchemaException.LIST_TOO_LONG, getLengthExceptionArgument());
    } else {
      value.forEach((item) => schema.validate(item));
    }
  }
  */
}
