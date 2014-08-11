part of ormicida.orm.schema;

class SchemaAlias {
  /// The label of this alias.
  final String  label;
  /// The description of this alias.
  final String  description;
  /// The name of the alias, used externally.
  final String  name;
  /// The type associated to this alias.
  final Type    type;
  /// The schema used for validation.
  final IsObject schema;
  
  /// Constructor.
  const SchemaAlias(this.name, this.type, this.schema,
      {this.label: null, this.description: null});
}

abstract class IsTypedObject extends Schema {
  /// Constructor.
  const IsTypedObject(bool nullable): super(nullable);
  
  /// Get the registered [SchemaAlias] for given [type].
  /// Throws a [SchemaException] if not found.
  SchemaAlias getByType(Type type);

  /// Get the registered [SchemaAlias] for given [name].
  /// Throws a [SchemaException] if not found.
  SchemaAlias getByName(String name);
  
  /// Get the registered [SchemaAlias] for given [value].
  /// Throws a [SchemaException] if not found.
  SchemaAlias getByValue(value) => getByType(value.runtimeType);

  /// Get the registered schema for given [type].
  /// Throws a [SchemaException] if not found.
  IsObject getSchemaByType(Type type) => getByType(type).schema;

  /// Get the registered schema for given [value].
  /// Throws a [SchemaException] if not found.
  IsObject getSchemaByValue(value) => getSchemaByType(value.runtimeType);

  /// Get the registered [SchemaAlias] for given name.
  /// Throws a [SchemaException] if not found.
  IsObject getSchemaByName(String name) => getByName(name).schema;
}

class IsUnion extends IsTypedObject {
  final List<SchemaAlias> aliases;
  
  const IsUnion(this.aliases, {bool nullable: false}): super(nullable);
  
  @override
  SchemaAlias getByType(Type type) =>
      aliases.firstWhere((alias) => alias.type == type, orElse: () {
        throw new ArgumentError('Union does not support given type:  $type');
      });
  
  @override
  SchemaAlias getByName(String name) =>
      aliases.firstWhere((alias) => alias.name == name, orElse: () {
        throw new SchemaException(SchemaException.UNSUPPORTED_ALIAS, {
          'alias': name,
          'aliases': aliases.map((alias) => alias.name).toList(growable: false)
        });
      });
}
