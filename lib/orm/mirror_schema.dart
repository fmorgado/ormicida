library ormicida.orm.mirror_schema;

import 'dart:mirrors';

import 'package:ormicida/orm/schema.dart';

class MirrorField extends Field {
  final Symbol symbol;
  
  const MirrorField(String name, this.symbol, Schema schema, {defaultValue})
      : super(name, schema, defaultValue);
  
  @override
  getValue(target) => reflect(target).getField(symbol).reflectee;
  
  @override
  void setValue(target, value) { reflect(target).setField(symbol, value); }
}

class MirrorFinalField extends Field {
  final Symbol symbol;
  
  const MirrorFinalField(String name, this.symbol, Schema schema, {defaultValue})
      : super(name, schema, defaultValue);
  
  @override
  getValue(target) => reflect(target).getField(symbol).reflectee;
  
  @override
  void setValue(Map target, value) { target[name] = value; }
}

class MirrorDefaultConstructor {
  final Type                  type;
  final Symbol                name;
  final List                  positional;
  final Map<Symbol, dynamic>  named;
  
  const MirrorDefaultConstructor(this.type, {
    this.name: const Symbol(''),
    this.positional: const [],
    this.named: null
  });
  
  InstanceMirror newInstanceMirror() =>
      reflectClass(type).newInstance(name, positional, named);
  
  dynamic call() => newInstanceMirror().reflectee;
}

class MirrorJsonConstructor {
  final Type                type;
  final Symbol              name;
  final List<String>        positional;
  final Map<Symbol, String> named;
  
  const MirrorJsonConstructor(this.type, {
    this.name: const Symbol(''),
    this.positional: const <String>[],
    this.named: null
  });
  
  List<dynamic> _buildPositional(Map<String, dynamic> arguments) {
    if (positional == null) {
      return const [];
    } else {
      return new List.from(
          positional.map(
              (String name) => arguments[name]),
              growable: false);
    }
  }
  
  Map<Symbol, dynamic> _buildNamed(Map<String, dynamic> arguments) {
    if (named == null) {
      return null;
    } else {
      final result = {};
      named.forEach((Symbol key, String value) {
        result[key] = arguments[value];
      });
      return result;
    }
  }
  
  InstanceMirror newInstanceMirror(Map<String, dynamic> arguments) =>
      reflectClass(type).newInstance(name,
          _buildPositional(arguments), _buildNamed(arguments));
  
  dynamic call(Map<String, dynamic> arguments) =>
      newInstanceMirror(arguments).reflectee;
}
