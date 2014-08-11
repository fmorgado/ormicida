library test.ormicida.codecs.json;

import 'dart:convert' show UTF8;
import 'dart:typed_data';
import 'package:unittest/unittest.dart';
import 'package:unittest/vm_config.dart';
//import 'package:unittest/html_config.dart';
import 'package:ormicida/codecs/json.dart';

void main() {
  //useHtmlConfiguration();
  useVMConfiguration();
  runTests();
}

void runTests() {
  group('json', () {
    group('decode', () {
      _decodeConstants();
      _decodeStrings();
      _decodeNumbers();
      _decodeLists();
      _decodeMaps();
      _decodeComplex();
      _decodeTypes();
    });
    group('encode', () {
      _encodeConstants();
      _encodeStrings();
      _encodeNumbers();
      _encodeLists();
      _encodeMaps();
      _encodeComplex();
    });
  });
}

void _decodeConstants() {
  group('constants', () {
    _expectDecodeFormatException('empty', '');
    _expectFormatException      ('empty', 'empty');
    _expectDecodeResult         ('null_1', 'null', null);
    _expectDecodeResult         ('null_2', 'NULL', null);
    _expectDecodeResult         ('null_3', 'NuLl', null);
    _expectFormatException      ('null_4', 'nult');
    _expectFormatException      ('null_5', 'null_');
    _expectFormatException      ('null_5', '-null');
    _expectDecodeResult         ('false_1', 'false', false);
    _expectDecodeResult         ('false_2', 'FALSE', false);
    _expectDecodeResult         ('false_3', 'FaLsE', false);
    _expectDecodeResult         ('true_1', 'true', true);
    _expectDecodeResult         ('true_2', 'TRUE', true);
    _expectDecodeResult         ('true_3', 'TrUe', true);
    _expectDecodeMatcher        ('nan1', 'nan', isNaN);
    _expectDecodeMatcher        ('nan2', 'NAN', isNaN);
    _expectDecodeMatcher        ('nan3', 'NaN', isNaN);
    _expectDecodeResult         ('inf_1', 'inf', double.INFINITY);
    _expectDecodeResult         ('inf_2', '+inf', double.INFINITY);
    _expectDecodeResult         ('inf_3', '-inf', double.NEGATIVE_INFINITY);
  });
}

void _decodeStrings() {
  group('strings', () {
    _expectDecodeResult         ('empty', '""', '');
    _expectDecodeResult         ('some', '"abc"', 'abc');
    _expectDecodeResult         ('utf8', r'"abc\u20ACaäĂ۞♣ﯠbc"', 'abc\u20ACaäĂ۞♣ﯠbc');
    _expectDecodeFormatException('unterminated', '"abc');
    _expectDecodeResult         ('escaped_1', r'"\b"', '\b');
    _expectDecodeResult         ('escaped_2', r'"\f"', '\f');
    _expectDecodeResult         ('escaped_3', r'"\n"', '\n');
    _expectDecodeResult         ('escaped_4', r'"\t"', '\t');
    _expectDecodeResult         ('escaped_5', r'"\r"', '\r');
    _expectDecodeResult         ('escaped_6', r'"\\"', r'\');
    _expectDecodeResult         ('escaped_7', r'"\/"', r'/');
    _expectDecodeResult         ('escaped_8', r'"\""', r'"');
    _expectDecodeResult         ('escaped_9', r'"\u0020"', ' ');
    _expectDecodeResult         ('escaped_10', r'"\u20AC"', '€');
    _expectDecodeResult         ('escaped_11', r'"0\b1\f2\n3\r4\t5\\6\/7\"8"', '0\b1\f2\n3\r4\t5\\6\/7\"8');
    _expectFormatException      ('escaped_12', r'"0\b1\f2\c3\r4\t5\\6\/7\"8"');
    _expectFormatException      ('escaped_13', r'"0\u"');
    _expectFormatException      ('escaped_14', r'"0\u001"');
    _expectDecodeResult         ('escaped_15', r'"0\u0009123"', '0\t123');
    _expectDecodeResult         ('escaped_16', r'"0\u0009123\u0077abc"', '0\t123wabc');
  });
}

void _decodeNumbers() {
  group('numbers', () {
    _expectDecodeResult   ('int1', '0', 0);
    _expectDecodeResult   ('int2', '-0', 0);
    _expectDecodeResult   ('int3', '+0', 0);
    _expectDecodeResult   ('int4', '34563563456', 34563563456);
    _expectDecodeResult   ('int5', '-34563563456', -34563563456);
    _expectDecodeResult   ('int6', '+34563563456', 34563563456);
    _expectDecodeResult   ('num1', '0.0', 0);
    _expectDecodeResult   ('num2', '0.0', 0.0);
    _expectDecodeResult   ('num3', '+0.0', 0.0);
    _expectDecodeResult   ('num4', '-0.0', 0.0);
    _expectDecodeResult   ('num5', '3456.567', 3456.567);
    _expectDecodeResult   ('num6', '-3456.567', -3456.567);
    _expectDecodeResult   ('num7', '+3456.567', 3456.567);
  });
}

void _decodeLists() {
  group('lists', () {
    _expectDecodeResult   ('empty1', '[]', []);
    _expectDecodeResult   ('empty2', '  [   ]    ', []);
    _expectFormatException('wrong1', '[,]');
  });
}

void _decodeMaps() {
  group('maps', () {
    _expectDecodeResult         ('empty1', '{}', {});
    _expectDecodeResult         ('empty2', '{    }', {});
    _expectFormatException      ('wrong1', '{,}');
    _expectFormatException      ('wrong2', '{   ,}');
    _expectDecodeFormatException('wrong2', '{"abc": "abc"  ');
    _expectDecodeResult         ('some1', '{"name": "John"}', {'name': 'John'});
    _expectDecodeResult         ('some1', '{"name": "John", }', {'name': 'John'});
  });
}

void _decodeComplex() {
  group('complex', () {
    _expectDecodeResult   ('1',
        r'[0, 123, -234.56, "abc", {"name": "Filipe", "age": 567, "books": [0,1,2,3,4], "size": 45.678}]',
        [0, 123, -234.56, 'abc', {'name': 'Filipe', 'age': 567, 'books': [0, 1, 2, 3, 4], 'size': 45.678}]);
  });
}

void _decodeTypes() {
  group('types', () {
    _expectDecodeResult   ('1',
        r'{"$type": "com.company.type", "name": "Filipe", "age": 567, "books": [0,1,2,3,4], "size": 45.678}',
        {r'$type': 'com.company.type', 'name': 'Filipe', 'age': 567, 'books': [0, 1, 2, 3, 4], 'size': 45.678});
  });
}

void _expectDecodeResult(String name, String jsonString, result) {
  _expectDecodeMatcher(name, jsonString, equals(result));
}

void _expectDecodeMatcher(String name, String jsonString, Matcher matcher) {
  final bytes = UTF8.encode(jsonString);
  test(name, () { expect(json.decode(bytes), matcher); });
}

void _expectFormatException(String name, String jsonString) {
  final bytes = UTF8.encode(jsonString);
  test(name, () {
    expect(() => json.decode(bytes), 
        throwsA(predicate((e) =>  e is FormatException)));
  });
}

void _expectDecodeFormatException(String name, String jsonString) {
  final bytes = UTF8.encode(jsonString);
  test(name, () {
    expect(() => json.decode(bytes), throwsA(predicate((e) =>  e is FormatException)));
  });
}

const _UNSUPPORTED_OBJECT     = 'json.unsupportedObject';
const _UNEXPECTED_CHAR        = 'json.unexpectedChar';
const _EMPTY_PROPERTY_NAME    = 'json.emptyPropertyName';
const _INVALID_ESCAPE         = 'json.invalidEscape';

void _encodeConstants() {
  group('constants', () {
    _expectEncodeResult         ('null', null, 'null');
    _expectEncodeResult         ('false', false, 'false');
    _expectEncodeResult         ('true', true, 'true');
    _expectEncodeResult         ('nan', double.NAN, 'nan');
    _expectEncodeResult         ('inf', double.INFINITY, 'inf');
    _expectEncodeResult         ('-inf', double.NEGATIVE_INFINITY, '-inf');
  });
}

void _encodeStrings() {
  group('strings', () {
    _expectEncodeResult         ('empty', '', '""');
    _expectEncodeResult         ('some', 'abc', '"abc"');
    _expectEncodeResult         ('utf8', 'ACaäĂ۞♣ﯠbc', '"ACaäĂ۞♣ﯠbc"');
    _expectEncodeResult         ('escape_1', '\b', r'"\b"');
    _expectEncodeResult         ('escape_2', '\f', r'"\f"');
    _expectEncodeResult         ('escape_3', '\n', r'"\n"');
    _expectEncodeResult         ('escape_4', '\t', r'"\t"');
    _expectEncodeResult         ('escape_5', '\r', r'"\r"');
    _expectEncodeResult         ('escape_6', '\\', r'"\\"');
    _expectEncodeResult         ('escape_7', '/', r'"/"');
    _expectEncodeResult         ('escape_8', '\/', r'"/"');
    _expectEncodeResult         ('escape_9', '"', r'"\""');
    _expectEncodeResult         ('escape_10', '€', r'"€"');
    _expectEncodeResult         ('binary_1',
                                  new Uint8List.fromList(const []),
                                  r'""');
    _expectEncodeResult         ('binary_2',
                                  new Uint8List.fromList(const [0]),
                                  r'"AA=="');
    _expectEncodeResult         ('binary_3',
                                  new Uint8List.fromList(const [1, 2, 3, 4, 5, 6, 7, 8, 9, 0]),
                                  r'"AQIDBAUGBwgJAA=="');
  });
}

void _encodeNumbers() {
  group('numbers', () {
    _expectEncodeResult   ('int1', 0, '0');
    _expectEncodeResult   ('int2', 34563563456, '34563563456');
    _expectEncodeResult   ('int3', -34563563456, '-34563563456');
    _expectEncodeResult   ('num1', 0.0, '0.0');
    _expectEncodeResult   ('num2', 3456.567, '3456.567');
    _expectEncodeResult   ('num3', -3456.567, '-3456.567');
  });
}

void _encodeLists() {
  group('lists', () {
    _expectEncodeResult   ('empty', [], '[]');
    _expectEncodeResult   ('some', [1, 2, 3, 4], '[1,2,3,4]');
  });
}

void _encodeMaps() {
  group('maps', () {
    _expectEncodeResult         ('empty', {}, '{}');
    _expectEncodeResult         ('empty', {'v1': 0, 'v2': 1}, '{"v1":0,"v2":1}');
  });
}

void _encodeComplex() {
  group('complex', () {
    _expectEncodeResult('1',
        [0, 123, -234.56, 'abc', {'name': 'Filipe', 'age': 567, 'books': [0, 1, 2, 3, 4], 'size': 45.678}],
        r'[0,123,-234.56,"abc",{"name":"Filipe","age":567,"books":[0,1,2,3,4],"size":45.678}]');
  });
}

void _expectEncodeResult(String name, object, String result) {
  _expectEncodeMatcher(name, object, equals(result));
}

void _expectEncodeMatcher(String name, object, Matcher matcher) {
  test(name, () { expect(UTF8.decode(json.encode(object)), matcher); });
}

/*
void _expectEncodeException(String name, object, String code, int position) {
  test(name, () {
    expect(() => json.decode(object), 
        throwsA(predicate((e) =>  e is JsonException
        && e.code == code && e.argument['position'] == position)));
  });
}
*/

const Matcher isNaN = const IsNaN();

class IsNaN extends Matcher {
  const IsNaN();
  bool matches(obj, Map matchState) => obj is num && obj.isNaN;
  Description describe(Description description) => description.add('is NaN');
}
