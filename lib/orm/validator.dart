library ormicida.orm.validator;

import 'package:ormicida/bytes/char.dart';
import 'package:ormicida/orm/schema.dart';

void _validateMap(final Map map, IsObject schema, final List stack) {
  final fields = schema.fields.toList();
  
  // Process existing fields
  map.forEach((String key, value) {
    stack.add(key);
    final field = fields.firstWhere((field) => field.name == key, orElse: () {
      throw new SchemaException(SchemaException.INVALID_FIELD);
    });
    fields.remove(field);
    map[key] = _validateValue(value, field.schema, stack);
    stack.removeLast();
  });
  
  // Process missing fields
  fields.forEach((field) {
    map[field.name] = field.getDefaultValue();
  });
}

dynamic _validateValue(final value, Schema schema, final List stack) {
  if (value == null) {
    if (! schema.nullable)
      throw new SchemaException(SchemaException.NOT_NULLABLE);
    return null;
    
  } else if (schema is IsDynamic) {
    return schema.normalizeAndValidate(value);
    
  } else if (schema is IsList) {
    if (value is! List)
      throw new SchemaException(SchemaException.NOT_A_LIST);
    
    final int length = value.length;
    final Schema itemSchema = schema.schema;
    for (int index = 0; index < length; index ++) {
      stack.add(index);
      value[index] = _validateValue(value[index], itemSchema, stack);
      stack.removeLast();
    }
    
    return value;
    
  } else if (schema is IsObject) {
    if (value is! Map)
      throw new SchemaException(SchemaException.NOT_A_MAP);
    _validateMap(value, schema, stack);
    return value;
    
  } else {
    assert(schema is IsUnion);
    if (value is! Map)
      throw new SchemaException(SchemaException.NOT_A_MAP);
    if (! value.containsKey(r'$type'))
      throw new SchemaException(SchemaException.NOT_TYPED);
    _validateMap(value,
        (schema as IsUnion).getSchemaByName(value[r'$type']), stack);
    return value;
  }
}

String _joinStack(final List stack) {
  final buffer = new StringBuffer();
  stack.forEach((element) {
    if (element is int) {
      buffer.write('[$element]');
    } else {
      assert(element is String);
      if (buffer.length > 0)
        buffer.writeCharCode(Char.POINT);
      buffer.write(element);
    }
  });
  return buffer.toString();
}

dynamic validate(final value, Schema schema) {
  final List stack = [];
  try {
    return _validateValue(
        value, schema != null ? schema : const IsDynamic(true), stack);
  } on SchemaException catch(exception) {
    exception.argument['path'] = _joinStack(stack);
    rethrow;
  }
}
