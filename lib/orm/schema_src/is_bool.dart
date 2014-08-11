part of ormicida.orm.schema;

class IsBool extends IsDynamic {
  const IsBool({bool nullable: false}): super(nullable);
  
  Object normalizeAndValidate(value) {
    if (value is! bool)
      throw new SchemaException(SchemaException.NOT_A_BOOLEAN);
    return value;
  }
}
