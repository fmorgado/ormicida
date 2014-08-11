library ormicida.orm.schema_cache;

import 'package:ormicida/orm/schema.dart';

final _schemaCache = <SchemaAlias>[];

void registerSchemaAlias() {
  
}

SchemaAlias getSchemaAliasByType(Type type) =>
    _schemaCache.firstWhere((alias) => alias.type == type, orElse: () {
      throw new ArgumentError('Union does not support given type:  $type');
    });

SchemaAlias getSchemaAliasByName(String name) =>
    _schemaCache.firstWhere((alias) => alias.name == name, orElse: () {
      throw new SchemaException(
          SchemaException.UNSUPPORTED_ALIAS, {'alias': name});
    });

class IsAlias extends IsTypedObject {
  final String name;
  final RegExp pattern;
  
  const IsAlias(this.name, {this.pattern, bool nullable})
      : super(nullable);
  
  @override
  SchemaAlias getByType(Type type) =>
      getSchemaAliasByType(type);
  
  @override
  SchemaAlias getByName(String name) {
    if (pattern != null) {
      if (! pattern.hasMatch(name)) {
        throw new SchemaException(
            SchemaException.UNSUPPORTED_ALIAS, {'alias': name});
      }
    }
    return getSchemaAliasByName(name);
  }
}
