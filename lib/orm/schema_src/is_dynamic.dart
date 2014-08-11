part of ormicida.orm.schema;

class IsDynamic extends Schema {
  /// Constructor.
  const IsDynamic([bool nullable = true]): super(nullable);
  
  /// Validate a value.
  dynamic normalizeAndValidate(value) => value;
}
