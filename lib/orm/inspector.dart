library ormicida.orm.inspector;

import 'dart:typed_data';

import 'package:ormicida/codec.dart';
import 'package:ormicida/orm/schema.dart';

final Inspector inspector = new Inspector();

class Inspector {
  final List<Object>  _seen = [];
  CodecListener       _listener;
  bool                _omitDefaultValues;
  
  Inspector();
  
  void clear() {
    _seen.clear();
    _listener = null;
  }
  
  void _pushSeen(object) {
    if (_seen.contains(object))
      throw new CyclicError(object);
    _seen.add(object);
  }
  
  void _popSeen() {
    _seen.removeLast();
  }
  
  void inspect(object, CodecListener listener, Schema schema,
        {bool omitDefaultValues: true}) {
    clear();
    _listener = listener;
    _omitDefaultValues = omitDefaultValues;
    _inspect(object, schema);
  }
  
  void _inspectObject(final object, final IsObject schema, final String type){
      final fields = schema.fields;
      _pushSeen(object);
      _listener.onMapStart(type);
      schema.fields.forEach((Field field) {
        final value = field.getValue(object);
        if (! _omitDefaultValues || value != field.defaultValue) {
          _listener.onPropertyStart(field.name);
          _inspect(value, field.schema);
          _listener.onPropertyEnd();
        }
      });
      _listener.onMapEnd();
      _popSeen();
  }
  
  void _inspect(final object, final Schema schema) {
    if (object == null) {
      _listener.onValue(null);
      
    } else if (schema is IsDynamic || schema == null) {
      if (object is Map) {
        _pushSeen(object);
        _listener.onMapStart();
        object.forEach((String key, value) {
          _listener.onPropertyStart(key);
          _inspect(value, null);
          _listener.onPropertyEnd();
        });
        _listener.onMapEnd();
        _popSeen();
        
      } else if (object is List && object is! TypedData) {
        _pushSeen(object);
        _listener.onListStart();
        final length = object.length;
        for (var index = 0; index < length; index++) {
          _inspect(object[index], null);
          _listener.onListElement();
        }
        _listener.onListEnd();
        _popSeen();
        
      } else {
        // Will throw if not supported.
        _listener.onValue(object);
      }
      
    } else if (schema is IsObject) {
      _inspectObject(object, schema, null);
      
    } else if (schema is IsList) {
      assert(object is List && object is! TypedData);
      final itemSchema = schema.schema;
      
      _pushSeen(object);
      _listener.onListStart();
      final length = object.length;
      for (var index = 0; index < length; index++) {
        _inspect(object[index], itemSchema);
        _listener.onListElement();
      }
      _listener.onListEnd();
      _popSeen();
      
    } else if (schema is IsUnion) {
      final alias = schema.getByValue(object);
      if (alias == null)
        throw new ArgumentError('Value not supported by union: $object');
      _inspectObject(object, alias.schema, alias.name);
      
    } else {
      throw new ArgumentError('Unknown schema type: schema');
    }
  }
  
  void encodeTo(object, CodecEncoder encoder, Schema schema,
                Buffer output, {bool omitDefaultValues: true}) {
    encoder.initialize(output);
    inspect(object, encoder, schema, omitDefaultValues: omitDefaultValues);
    encoder.clear();
  }
  
  List<int> encode(object, CodecEncoder encoder,
      Schema schema, {bool omitDefaultValues: true}) {
    globalBuffer.clear();
    encodeTo(object, encoder, schema,
        globalBuffer, omitDefaultValues: omitDefaultValues);
    final result = globalBuffer.bytes;
    globalBuffer.clear();
    return result;
  }
  
  String stringify(object, Schema schema) {
    final stringifier = new Stringifier();
    inspect(object, stringifier, schema);
    return stringifier.getResult();
  }
  
  void printObject(object, Schema schema) =>
    print(stringify(object, schema));
}
