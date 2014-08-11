part of ormicida.orm.schema;

abstract class Field {
  /// The name of field.
  final String  name;
  /// The schema used to validate the field.
  final Schema  schema;
  /// The default value of the field.
  final         defaultValue;
  
  /// Constructor.
  const Field(this.name, this.schema, this.defaultValue);
  
  /// Get the value of the field from the given [target].
  dynamic getValue(target);
  
  /// Set the value of the field on the given [target].
  void setValue(target, value);
  
  /// Sets the field's default value.
  /// Throws if the default is null and the value is not nullable.
  void setDefaultValue(target) {
    if (defaultValue != null) {
      setValue(target, defaultValue);
    } else if (schema.nullable) {
      setValue(target, null);
    } else {
      throw new SchemaException(SchemaException.MISSING_FIELD, {'name': name});
    }
  }
}

class MapField extends Field {
  const MapField(String name, Schema schema, {defaultValue})
      : super(name, schema, defaultValue);
  
  @override
  getValue(Map target) => target[name];
  
  @override
  void setValue(target, value) { target[name] = value; }
}

typedef dynamic FieldGetter(target);
typedef void FieldSetter(target, value);

class ClassField extends Field {
  final FieldGetter getter;
  final FieldSetter setter;
  
  const ClassField(String name, Schema schema,
      this.getter, this.setter, {defaultValue})
      : super(name, schema, defaultValue);
  
  @override
  dynamic getValue(target) => getter(target);
  
  @override
  void setValue(target, value) { setter(target, value); }
}

class ClassFinalField extends Field {
  final FieldGetter getter;
  
  const ClassFinalField(String name, Schema schema,
      this.getter, {defaultValue})
      : super(name, schema, defaultValue);
  
  @override
  dynamic getValue(target) => getter(target);
  
  @override
  void setValue(Map target, value) { target[name] = value; }
}

/// Defines a method that allocates an instance.
typedef dynamic DefaultConstructor();

/// Defines a method that allocates an instance,
/// using [values] for initialization.
typedef dynamic JsonConstructor(Map<String, dynamic> values);

class IsObject extends Schema {
  /// The fields of the object.
  final List<Field> fields;
  final DefaultConstructor  constructor;
  final JsonConstructor     finalizer;
  
  const IsObject(this.fields, {this.constructor,
    this.finalizer, bool nullable: false})
      : super(nullable);
  
  const IsObject.map(List<MapField> fields, {bool nullable: false})
      : this.fields = fields,
        constructor = null,
        finalizer = null,
        super(nullable);
  
  const IsObject.mutable(List<ClassField> fields, this.constructor,
      {this.finalizer, bool nullable: false})
      : this.fields = fields,
        super(nullable);
  
  const IsObject.immutable(List<ClassFinalField> fields, this.finalizer,
      {bool nullable: false})
      : this.fields = fields,
        constructor = null,
        super(nullable);
}
