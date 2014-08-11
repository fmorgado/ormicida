library ormicida.orm.builder;

import 'package:ormicida/bytes/char.dart';
import 'package:ormicida/codec.dart';
import 'package:ormicida/orm/schema.dart';

final Builder builder = new Builder();

class Builder implements CodecListener {
  final List<_Wrapper>  _stack = [];
  _Wrapper              _wrapper;
  var                   _value;
  Schema                _schema;
  
  Builder();
  
  void clear() {
    // TODO cache wrappers
    _stack.clear();
    _wrapper = null;
    _schema = null;
    _value = null;
  }
  
  void _pushWrapper(_Wrapper wrapper) {
    if (_wrapper != null) _stack.add(_wrapper);
    _wrapper = wrapper;
  }
  
  void _popWrapper() {
    assert(_wrapper != null);
    _value = _wrapper.finalize();
    _wrapper = _stack.length > 0 ? _stack.removeLast() : null;
  }
  
  void onValue(value) {
    assert(_schema != null);
    final schema = _schema;
    
    if (value == null) {
      if (! schema.nullable)
        throw new SchemaException(SchemaException.NOT_NULLABLE);
      
    } else if (schema is IsDynamic) {
      value = schema.normalizeAndValidate(value);
      
    } else {
      throw new SchemaException(
          schema is IsList
            ? SchemaException.NOT_A_LIST
            : schema is IsUnion
                ? SchemaException.NOT_TYPED
                : SchemaException.NOT_AN_OBJECT);
    }
    
    _value = value;
  }
  
  void onPropertyStart(String name) {
    assert(_wrapper is _ObjectWrapper);
    _schema = (_wrapper as _ObjectWrapper).resolveField(name);
  }
  
  void onPropertyEnd() {
    assert(_wrapper is _ObjectWrapper);
    (_wrapper as _ObjectWrapper).setFieldValue(_value);
  }
  
  void onMapStart([String alias]) {
    final schema = _schema;
    
    if (alias != null) {
      if (schema is! IsUnion) {
        throw new SchemaException(
            SchemaException.UNEXPECTED_ALIAS, {'alias': alias});
      }
      _pushWrapper(new _SchemaWrapper(schema.getSchemaByName(alias)));
      
    } else if (schema is IsDynamic) {
      final wrapper = new _DynamicWrapper();
      schema.normalizeAndValidate(wrapper.map);
      _pushWrapper(wrapper);
      
    } else if (schema is IsObject) {
      _pushWrapper(new _SchemaWrapper(schema));
      
    } else if (schema is IsList) {
      throw new SchemaException(SchemaException.NOT_A_LIST);
      
    } else {
      assert(schema is IsUnion);
      throw new SchemaException(SchemaException.ALIAS_EXPECTED);
    }
  }
  
  void onMapEnd() {
    assert(_wrapper is _ObjectWrapper);
    _popWrapper();
  }
  
  void onListStart() {
    final schema = _schema;
    
    final list = [];
    
    _ListWrapper wrapper;
    if (schema is IsList) {
      wrapper = new _ListWrapper.isList(schema);
      
    } else if (schema is IsDynamic) {
      wrapper = new _ListWrapper.isDynamic();
      schema.normalizeAndValidate(wrapper.list);
      
    } else {
      assert(schema is IsObject || schema is IsUnion);
      throw new SchemaException(
          schema is IsObject
              ? SchemaException.NOT_AN_OBJECT
              : SchemaException.NOT_TYPED);
    }
    
    _schema = wrapper.itemSchema;
    _pushWrapper(wrapper);
  }
  
  void onListElement() {
    assert(_wrapper is _ListWrapper);
    final wrapper = _wrapper as _ListWrapper;
    wrapper.addElement(_value);
    _schema = wrapper.itemSchema;
  }
  
  void onListEnd() {
    assert(_wrapper is _ListWrapper);
    _popWrapper();
  }
  
  String _getCurrentPath() {
    final buffer = new StringBuffer();
    
    void addWrapperPath(_Wrapper wrapper) {
      final element = wrapper.getPathElement();
      if (element is int) {
        buffer.write('[$element]');
      } else {
        assert(element is String);
        if (buffer.length > 0)
          buffer.writeCharCode(Char.POINT);
        buffer.write(element);
      }
    }
    
    _stack.forEach(addWrapperPath);
    if (_wrapper != null)
      addWrapperPath(_wrapper);
    
    return buffer.toString();
  }
  
  Object decodeFrom(Buffer input, CodecDecoder decoder, Schema schema) {
    clear();
    _schema = schema != null ? schema : const IsDynamic(true);
    
    try {
      decoder.decodeTo(input, this);
    } catch (exception) {
      if (exception is SchemaException) {
        exception.argument['path'] = _getCurrentPath();
      }
      clear();
      rethrow;
    }
    
    if (_stack.length > 0)
      throw new StateError('Unterminated objects after running decoder');
    
    final result = _value;
    clear();
    return result;
  }
  
  Object decode(List<int> bytes, CodecDecoder decoder, Schema schema) =>
      decodeFrom(new Buffer.fromBytes(bytes), decoder, schema);
}

abstract class _Wrapper {
  dynamic getPathElement();
  dynamic finalize();
}

class _ListWrapper extends _Wrapper {
  final List    list = [];
  final int     minLen;
  final int     maxLen;
  final Schema  itemSchema;
  
  _ListWrapper.isDynamic()
      : minLen = null,
        maxLen = null,
        itemSchema = const IsDynamic(true);
  
  _ListWrapper.isList(IsList schema)
      : minLen = schema.minLen,
        maxLen = schema.maxLen,
        itemSchema = schema.schema;
  
  void addElement(element) {
    if (maxLen != null && list.length >= maxLen) {
      throw new SchemaException(SchemaException.LIST_TOO_LONG);
    }
    list.add(element);
  }
  
  Map _getBoundsArgument() {
    final result = {};
    if (minLen != null) result['min'] = minLen;
    if (maxLen != null) result['max'] = maxLen;
    return result;
  }
  
  List finalize() {
    if (minLen != null && list.length < minLen) {
      throw new SchemaException(SchemaException.LIST_TOO_SHORT,
          _getBoundsArgument());
    }
    return list;
  }
  
  int getPathElement() => list.length;
}

abstract class _ObjectWrapper extends _Wrapper {
  final List<String> _fieldNames = <String>[];
  
  void _addFieldName(String name) {
    if (_fieldNames.contains(name)) {
      throw new SchemaException(SchemaException.DUPLICATED_FIELD, {'name': name});
    }
    _fieldNames.add(name);
  }
  
  Schema resolveField(String name);
  
  void setFieldValue(value);
}

class _DynamicWrapper extends _ObjectWrapper {
  final Map map = {};
  String _fieldName;
  
  _DynamicWrapper();
  
  Schema resolveField(String name) {
    _addFieldName(name);
    _fieldName = name;
    return const IsDynamic(true);
  }
  
  void setFieldValue(value) {
    map[_fieldName] = value;
  }
  
  Map finalize() => map;
  
  String getPathElement() => _fieldName;
}

class _SchemaWrapper extends _ObjectWrapper {
  final             _result;
  final List<Field> _fields;
  Field             _field;
  
  _SchemaWrapper(IsObject schema)
      : _fields = schema.fields.toList(),
        _result = schema.constructor != null ? schema.constructor() : {};
  
  Field _getAndRemoveField(String name, List<Field> fields) {
    Field field;
    final length = fields.length;
    for (int index = 0; index < length; index ++) {
      field = fields[index];
      if (field.name == name) {
        fields.removeAt(index);
        break;
      }
    }
    if (field == null) {
      throw new SchemaException(SchemaException.INVALID_FIELD, {'name': name});
    }
    return field;
  }
  
  Schema resolveField(String name) {
    _addFieldName(name);
    _field = _getAndRemoveField(name, _fields);
    return _field.schema;
  }
  
  void setFieldValue(value) {
    _field.setValue(_result, value);
  }
  
  dynamic finalize() {
    final result = _result;
    // Process missing fields
    _fields.forEach((field) {
      field.setDefaultValue(result);  // May throw.
    });
    return result;
  }
  
  String getPathElement() => _field != null ? _field.name : null;
}
