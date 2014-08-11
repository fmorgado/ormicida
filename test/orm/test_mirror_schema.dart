library test.ormicida.orm.mirror_schema;

import 'package:unittest/unittest.dart';
import 'package:unittest/vm_config.dart';
import 'package:ormicida/orm/schema.dart';
import 'package:ormicida/orm/mirror_schema.dart';

import '_definitions.dart';

void main() {
  useVMConfiguration();
  runTests();
}

void runTests() {
  group('MirrorField', () {
    final object = new Simple2(x: 56, y: 34);
    final field = new MirrorField('x', #x, const IsNum());
    test('Getter', () {
      expect(field.getValue(object), equals(56));
    });
    test('Setter', () {
      field.setValue(object, 45);
      expect(object.x, equals(45));
    });
  });
  
  group('default constructor', () {
    
    group('simple', () {
      
      test('default', () {
        expect(
            const MirrorDefaultConstructor(_SimpleTestClass)().toString(),
            equals('Simple(v1=null, v2=null)'));
      });
      
      test('initialized', () {
        expect(
          const MirrorDefaultConstructor(_SimpleTestClass,
            name: const Symbol('initialized')
          )().toString(),
            equals('Simple(v1=false, v2=0)'));
      });
      
      test('positional_1', () {
        expect(
          const MirrorDefaultConstructor(_SimpleTestClass,
            name: const Symbol('positional'),
            positional: const [true]
          )().toString(),
            equals('Simple(v1=true, v2=0)'));
      });
      
      test('positional_2', () {
        expect(
          const MirrorDefaultConstructor(_SimpleTestClass,
            name: const Symbol('positional'),
            positional: const [true, 1]
          )().toString(),
            equals('Simple(v1=true, v2=1)'));
      });
      
      test('named_1', () {
        expect(
          const MirrorDefaultConstructor(_SimpleTestClass,
            name: const Symbol('named'),
            positional: const [true]
          )().toString(),
            equals('Simple(v1=true, v2=0)'));
      });
      
      test('named_2', () {
        expect(
          new MirrorDefaultConstructor(_SimpleTestClass,
            name: const Symbol('named'),
            positional: const [true],
            named: {const Symbol('v2'): 1}
          )().toString(),
            equals('Simple(v1=true, v2=1)'));
      });
    });
    
    group('const constructor', () {
      
      test('default', () {
        expect(
            const MirrorDefaultConstructor(_ConstTestClass)().toString(),
            equals('Const(v1=false, v2=0)'));
      });
      
      test('positional_1', () {
        expect(
          const MirrorDefaultConstructor(_ConstTestClass,
            name: const Symbol('positional'),
            positional: const [true]
          )().toString(),
            equals('Const(v1=true, v2=0)'));
      });
      
      test('positional_2', () {
        expect(
          const MirrorDefaultConstructor(_ConstTestClass,
            name: const Symbol('positional'),
            positional: const [true, 1]
          )().toString(),
            equals('Const(v1=true, v2=1)'));
      });
      
      test('named_1', () {
        expect(
          const MirrorDefaultConstructor(_ConstTestClass,
            name: const Symbol('named'),
            positional: const [true]
          )().toString(),
            equals('Const(v1=true, v2=0)'));
      });
      
      test('named_2', () {
        expect(
          new MirrorDefaultConstructor(_ConstTestClass,
            name: const Symbol('named'),
            positional: const [true],
            named: {const Symbol('v2'): 1}
          )().toString(),
            equals('Const(v1=true, v2=1)'));
      });
    });
  });
  
  group('custom', () {
    
    group('simple', () {
      
      test('default', () {
        expect(
          const MirrorJsonConstructor(_SimpleTestClass)(const {}).toString(),
          equals('Simple(v1=null, v2=null)'));
      });
      
      test('initialized', () {
        expect(
          const MirrorJsonConstructor(_SimpleTestClass,
            name: const Symbol('initialized')
          )(const {}).toString(),
            equals('Simple(v1=false, v2=0)'));
      });
      
      test('positional_1', () {
        expect(
          const MirrorJsonConstructor(_SimpleTestClass,
            name: const Symbol('positional'),
            positional: const ['value1']
          )(const {'value1': true}).toString(),
            equals('Simple(v1=true, v2=0)'));
      });
      
      test('positional_2', () {
        expect(
          const MirrorJsonConstructor(_SimpleTestClass,
            name: const Symbol('positional'),
            positional: const ['value1', 'value2']
          )(const {'value1': true, 'value2': 1}).toString(),
            equals('Simple(v1=true, v2=1)'));
      });
      
      test('named_1', () {
        expect(
          const MirrorJsonConstructor(_SimpleTestClass,
            name: const Symbol('named'),
            positional: const ['value1']
          )(const {'value1': true}).toString(),
            equals('Simple(v1=true, v2=0)'));
      });
      
      test('named_2', () {
        expect(
          new MirrorJsonConstructor(_SimpleTestClass,
            name: const Symbol('named'),
            positional: const ['value1'],
            named: {const Symbol('v2'): 'value2'}
          )(const {'value1': true, 'value2': 1}).toString(),
            equals('Simple(v1=true, v2=1)'));
      });
    });
    
    group('const', () {
      
      test('default', () {
        expect(
          const MirrorJsonConstructor(_ConstTestClass)(const {}).toString(),
          equals('Const(v1=false, v2=0)'));
      });
      
      test('positional_1', () {
        expect(
          const MirrorJsonConstructor(_ConstTestClass,
            name: const Symbol('positional'),
            positional: const ['value1']
          )(const {'value1': true}).toString(),
            equals('Const(v1=true, v2=0)'));
      });
      
      test('positional_2', () {
        expect(
          const MirrorJsonConstructor(_ConstTestClass,
            name: const Symbol('positional'),
            positional: const ['value1', 'value2']
          )(const {'value1': true, 'value2': 1}).toString(),
            equals('Const(v1=true, v2=1)'));
      });
      
      test('named_1', () {
        expect(
          const MirrorJsonConstructor(_ConstTestClass,
            name: const Symbol('named'),
            positional: const ['value1']
          )(const {'value1': true}).toString(),
            equals('Const(v1=true, v2=0)'));
      });
      
      test('named_2', () {
        expect(
          new MirrorJsonConstructor(_ConstTestClass,
            name: const Symbol('named'),
            positional: const ['value1'],
            named: {const Symbol('v2'): 'value2'}
          )(const {'value1': true, 'value2': 1}).toString(),
            equals('Const(v1=true, v2=1)'));
      });
    });
  });
}

class _SimpleTestClass {
  bool    v1;
  int     v2;
  
  _SimpleTestClass();
  
  _SimpleTestClass.initialized(): v1 = false, v2 = 0;
  
  _SimpleTestClass.positional(this.v1, [this.v2 = 0]);
  
  _SimpleTestClass.named(this.v1, {this.v2: 0});
  
  String toString() => 'Simple(v1=$v1, v2=$v2)';
}

class _ConstTestClass {
  final bool    v1;
  final int     v2;
  
  factory _ConstTestClass.fromJson(Map params) {
    return new _ConstTestClass.named(params['v1'], v2: params['v2']);
  }
  
  const _ConstTestClass(): v1 = false, v2 = 0;
  
  const _ConstTestClass.positional(this.v1, [this.v2 = 0]);
  
  const _ConstTestClass.named(this.v1, {this.v2: 0});
  
  Map toJson() => {'v1': v1, 'v2': v2};
  
  String toString() => 'Const(v1=$v1, v2=$v2)';
}
