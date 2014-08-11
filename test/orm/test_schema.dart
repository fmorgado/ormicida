library test.ormicida.orm.schema;

import 'package:unittest/unittest.dart';
import 'package:unittest/vm_config.dart';
//import 'package:unittest/html_config.dart';

import 'package:ormicida/orm/schema.dart';
//import 'package:ormicida/orm/mirror_schema.dart';

import '../_utils.dart';
import '_definitions.dart';

void main() {
  //useHtmlConfiguration();
  useVMConfiguration();
  runTests();
}

void runTests() {
  group('schema', () {
    group('IsDynamic', () {
      _testIsDynamic(const IsDynamic(true), null, name: 'nullable');
      _testIsDynamic(const IsDynamic(false), null);
      _testIsDynamic(const IsDynamic(), false);
      _testIsDynamic(const IsDynamic(), true);
      _testIsDynamic(const IsDynamic(), 0);
      _testIsDynamic(const IsDynamic(), 1.1);
      _testIsDynamic(const IsDynamic(), 'abc');
      _testIsDynamic(const IsDynamic(), []);
      _testIsDynamic(const IsDynamic(), {});
    });
    
    group('IsBool', () {
      _failIsDynamic(const IsBool(nullable: true), null, name: 'nullable');
      _failIsDynamic(const IsBool(), null);
      _testIsDynamic(const IsBool(), false);
      _testIsDynamic(const IsBool(), true);
      _failIsDynamic(const IsBool(), 0);
      _failIsDynamic(const IsBool(), 1.1);
      _failIsDynamic(const IsBool(), 'abc');
      _failIsDynamic(const IsBool(), []);
      _failIsDynamic(const IsBool(), {});
    });
    
    group('IsMap', () {
      _failIsDynamic(const IsMap(nullable: true), null, name: 'nullable');
      _failIsDynamic(const IsMap(), null);
      _failIsDynamic(const IsMap(), false);
      _failIsDynamic(const IsMap(), true);
      _failIsDynamic(const IsMap(), 0);
      _failIsDynamic(const IsMap(), 1.1);
      _failIsDynamic(const IsMap(), 'abc');
      _failIsDynamic(const IsMap(), []);
      _testIsDynamic(const IsMap(), {});
      _testIsDynamic(const IsMap(), {'a': 0});
    });
    
    /*
    group('IsId', () {
      _failIsDynamic(const IsId(nullable: true),
          null, name: 'nullable');
      _failIsDynamic(const IsId(), null);
      _failIsDynamic(const IsId(), false);
      _failIsDynamic(const IsId(), true);
      _failIsDynamic(const IsId(), 0);
      _testIsDynamic(const IsId(), const SchemaId(const [0]));
      _testIsDynamic(const IsId(), 'AA==',
          matcher: equals(const SchemaId(const [0])));
      _failIsDynamic(const IsId(), 1.1);
      _failIsDynamic(const IsId(), 'abc');
      _failIsDynamic(const IsId(), []);
      _failIsDynamic(const IsId(), {});
    });
    */
    
    group('IsInt', () {
      _failIsDynamic(const IsInt(nullable: true), null, name: 'nullable');
      _failIsDynamic(const IsInt(), null);
      _failIsDynamic(const IsInt(), false);
      _failIsDynamic(const IsInt(), true);
      _testIsDynamic(const IsInt(), 0);
      _testIsDynamic(const IsInt(min: 0), 0, name: 'min_1');
      _failIsDynamic(const IsInt(min: 0), -1, name: 'min_2');
      _testIsDynamic(const IsInt(max: 10), 0, name: 'max_1');
      _failIsDynamic(const IsInt(max: 10), 11, name: 'max_2');
      _failIsDynamic(const IsInt(), 1.1);
      _failIsDynamic(const IsInt(), 'abc');
      _failIsDynamic(const IsInt(), []);
      _failIsDynamic(const IsInt(), {});
    });
    
    group('IsDuration', () {
      _failIsDynamic(const IsDuration(nullable: true), null, name: 'nullable');
      _failIsDynamic(const IsDuration(), null);
      _failIsDynamic(const IsDuration(), false);
      _failIsDynamic(const IsDuration(), true);
      _testIsDynamic(const IsDuration(), 2000,
          matcher: equals(const Duration(microseconds: 2000)));
      _testIsDynamic(const IsDuration(),
          const Duration(microseconds: 2000));
      _testIsDynamic(const IsDuration(
          min: const Duration(microseconds: 10)),
          const Duration(microseconds: 10), name: 'min_1');
      _failIsDynamic(const IsDuration(
          min: const Duration(microseconds: 10)),
          const Duration(microseconds: 9), name: 'min_2');
      _testIsDynamic(const IsDuration(
          max: const Duration(microseconds: 10)),
          const Duration(microseconds: 10), name: 'max_1');
      _failIsDynamic(const IsDuration(
          max: const Duration(microseconds: 10)),
          const Duration(microseconds: 11), name: 'max_2');
      _failIsDynamic(const IsDuration(), 1.1);
      _failIsDynamic(const IsDuration(), 'abc');
      _failIsDynamic(const IsDuration(), []);
      _failIsDynamic(const IsDuration(), {});
      _failIsDynamic(const IsDuration(), {'a': 0});
    });
    
    group('IsNum', () {
      _failIsDynamic(const IsNum(nullable: true), null, name: 'nullable');
      _failIsDynamic(const IsNum(), null);
      _failIsDynamic(const IsNum(), false);
      _failIsDynamic(const IsNum(), true);
      _testIsDynamic(const IsNum(), 0);
      _testIsDynamic(const IsNum(), 1.1);
      _failIsDynamic(const IsNum(), double.NAN, name: 'nan_1');
      _testIsDynamic(const IsNum(allowNaN: true),
          double.NAN, matcher: isNaN, name: 'nan_2');
      _failIsDynamic(const IsNum(),
          double.INFINITY, name: 'inf_1');
      _testIsDynamic(const IsNum(allowInf: true),
          double.INFINITY, name: 'inf_2');
      _failIsDynamic(const IsNum(),
          double.NEGATIVE_INFINITY, name: 'neg_inf_1');
      _testIsDynamic(const IsNum(allowNegInf: true),
          double.NEGATIVE_INFINITY, name: 'neg_inf_2');
      _failIsDynamic(const IsNum(min: 0), -1, name: 'min_1');
      _testIsDynamic(const IsNum(min: 0), 0, name: 'min_2');
      _failIsDynamic(const IsNum(max: 0), 1, name: 'max_1');
      _testIsDynamic(const IsNum(max: 0), 0, name: 'max_2');
      _failIsDynamic(const IsNum(minEx: 0), -1, name: 'minEx_1');
      _failIsDynamic(const IsNum(minEx: 0), 0, name: 'minEx_2');
      _testIsDynamic(const IsNum(minEx: 0), 1, name: 'minEx_3');
      _failIsDynamic(const IsNum(maxEx: 0), 1, name: 'maxEx_1');
      _failIsDynamic(const IsNum(maxEx: 0), 0, name: 'maxEx_2');
      _testIsDynamic(const IsNum(maxEx: 0), -1, name: 'maxEx_3');
      _failIsDynamic(const IsNum(), 'abc');
      _failIsDynamic(const IsNum(), []);
      _failIsDynamic(const IsNum(), {});
      _failIsDynamic(const IsNum(), {'a': 0});
    });
    
    group('IsString', () {
      _failIsDynamic(const IsString(nullable: true), null, name: 'nullable');
      _failIsDynamic(const IsString(), null);
      _failIsDynamic(const IsString(), false);
      _failIsDynamic(const IsString(), true);
      _failIsDynamic(const IsString(), 0);
      _failIsDynamic(const IsString(), 1.1);
      _testIsDynamic(const IsString(), 'abc');
      _failIsDynamic(const IsString(minLen: 3), 'ab', name: 'minLen_1');
      _testIsDynamic(const IsString(minLen: 3), 'abc', name: 'minLen_2');
      _failIsDynamic(const IsString(maxLen: 3), 'abcd', name: 'maxLen_1');
      _testIsDynamic(const IsString(maxLen: 3), 'abc', name: 'maxLen_2');
      _failIsDynamic(new IsString(
          pattern: new RegExp(r"(\d+)")), 'abc', name: 'regexp_1');
      _testIsDynamic(new IsString(
          pattern: new RegExp(r"(\d+)")), '123', name: 'regexp_2');
      _failIsDynamic(const IsString(
          options: const ['option1', 'options2']), 'abc', name: 'options_1');
      _testIsDynamic(const IsString(
          options: const ['option1', 'options2']), 'option1', name: 'options_2');
      _failIsDynamic(const IsString(), []);
      _failIsDynamic(const IsString(), {});
    });
    
    group('IsDateTime', () {
      _failIsDynamic(const IsDateTime(nullable: true), null, name: 'nullable');
      _failIsDynamic(const IsDateTime(), null);
      _failIsDynamic(const IsDateTime(), false);
      _failIsDynamic(const IsDateTime(), true);
      _testIsDynamic(const IsDateTime(), 0,
          matcher: equals(new DateTime.fromMillisecondsSinceEpoch(0)),
          name: 'int');
      _testIsDynamic(const IsDateTime(), '2014-01-24 00:00:00.000',
          matcher: equals(new DateTime(2014, 01, 24)), name: 'string');
      _testIsDynamic(const IsDateTime(),
          new DateTime(2014, 01, 24), name: 'date');
      _testIsDynamic(
          new IsDateTime(after: new DateTime(2014, 01, 24)),
          new DateTime(2014, 01, 24), name: 'after_1');
      _failIsDynamic(
          new IsDateTime(after: new DateTime(2014, 01, 24)),
          new DateTime(2014, 01, 23), name: 'after_2');
      _testIsDynamic(
          new IsDateTime(before: new DateTime(2014, 01, 24)),
          new DateTime(2014, 01, 24), name: 'before_1');
      _failIsDynamic(
          new IsDateTime(before: new DateTime(2014, 01, 24)),
          new DateTime(2014, 01, 25), name: 'before_2');
      _failIsDynamic(const IsDateTime(), 1.1);
      _failIsDynamic(const IsDateTime(), 'abc');
      _failIsDynamic(const IsDateTime(), []);
      _failIsDynamic(const IsDateTime(), {});
    });

    group('Fields', () {
      group('defaultValue', () {
        final map = {};
        test('nullable with default', () {
          const field = const MapField('v1', const IsDynamic(true), defaultValue: true);
          field.setDefaultValue(map);
          expect(map['v1'], equals(true));
        });
        test('non-nullable with default', () {
          const field = const MapField('v1', const IsDynamic(false), defaultValue: true);
          field.setDefaultValue(map);
          expect(map['v1'], equals(true));
        });
        test('nullable no default', () {
          const field = const MapField('v1', const IsDynamic(true));
          field.setDefaultValue(map);
          expect(map['v1'], equals(null));
        });
        test('non-nullable no default', () {
          const field = const MapField('v1', const IsDynamic(false));
          expect(() => field.setDefaultValue(map), throwsA(predicate((e) =>  e is SchemaException)));
        });
      });
      
      group('MapField', () {
        final object = {'v1': false};
        final field = const MapField('v1', const IsDynamic(true));
        test('Getter', () {
          expect(field.getValue(object), equals(false));
        });
        test('Setter', () {
          field.setValue(object, 45);
          expect(object['v1'], equals(45));
        });
      });
      
      group('ClassField', () {
        final object = {'v1': false};
        final field = new ClassField('v1',
            const IsDynamic(true),
            (Map target) => target['v1'],
            (Map target, value) { target['v1'] = value; });
        test('Getter', () {
          expect(field.getValue(object), equals(false));
        });
        test('Setter', () {
          field.setValue(object, 45);
          expect(object['v1'], equals(45));
        });
      });
    });
    
    group('IsUnion', () {
      final union = new IsUnion([
         new SchemaAlias('test.simple1', Simple1, SIMPLE_1_CLASS),
         new SchemaAlias('test.simple2', Simple2, SIMPLE_2_CLASS)
       ]);
      test('ByType', () {
        expect(union.getByType(Simple1), equals(union.aliases[0]));
        expect(union.getByType(Simple2), equals(union.aliases[1]));
        expect(() => union.getByType(List),
            throwsA(predicate((e) =>  e is ArgumentError)));
      });
      test('ByName', () {
        expect(union.getSchemaByName('test.simple1'),
            equals(union.aliases[0].schema));
        expect(union.getSchemaByName('test.simple2'),
            equals(union.aliases[1].schema));
        expect(() => union.getSchemaByName('inexistant'),
               throwsA(predicate((e) =>  e is SchemaException)));
      });
    });
    
  });
}

void _testIsDynamic(IsDynamic schema, value, {String name, Matcher matcher}) {
  test(name != null ? name : value.toString(), () {
    expect(schema.normalizeAndValidate(value), matcher != null ? matcher : equals(value));
  });
}

void _failIsDynamic(IsDynamic schema, value, {String name}) {
  if (name == null) name = value.toString();
  test(name, () {
    expect(() => schema.normalizeAndValidate(value), 
        throwsA(predicate((e) =>  e is SchemaException)));
  });
}
