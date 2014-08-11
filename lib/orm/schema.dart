library ormicida.orm.schema;

part 'schema_src/exceptions.dart';
part 'schema_src/is_bool.dart';
part 'schema_src/is_date_time.dart';
part 'schema_src/is_duration.dart';
part 'schema_src/is_dynamic.dart';
part 'schema_src/is_int.dart';
part 'schema_src/is_list.dart';
part 'schema_src/is_map.dart';
part 'schema_src/is_num.dart';
part 'schema_src/is_object.dart';
part 'schema_src/is_string.dart';
part 'schema_src/is_typed_object.dart';

const MAP_TYPE_PROPERTY = '\$type';

abstract class Schema {
  /// Indicates if the value is nullable.
  final bool nullable;
  
  /// Constructor.
  const Schema(this.nullable);
}

final _NULLABLE_FIELD = new ClassFinalField(
    'nullable',
    const IsBool(),
    (Schema schema) => schema.nullable,
    defaultValue: false);
/*
const ClassFinalField(String name, Schema schema,
    this.getter, {defaultValue})
    : super(name, schema, defaultValue);
*/
/*
final _schemaSchema = new IsObject.immutable();

const IsObject.immutable(List<ClassFinalField> fields, this.finalizer,
    {bool nullable: false})
    : this.fields = fields,
      constructor = null,
      super(nullable);
*/