part of ormicida.orm.schema;

class IsMap extends IsDynamic {
  const IsMap({bool nullable: false}): super(nullable);
  
  Object normalizeAndValidate(value) {
    if (value is! Map)
      throw new SchemaException(SchemaException.NOT_A_MAP);
    return value;
  }
}
