library test.ormicida.codecs.bson;

import 'dart:typed_data';
import 'package:unittest/unittest.dart';
import 'package:unittest/vm_config.dart';
//import 'package:unittest/html_config.dart';
import 'package:ormicida/codecs/bson.dart';
import 'package:ormicida/codec.dart';

void main() {
  useVMConfiguration();
  //useHtmlConfiguration();
  runTests();
}

void runTests() {
  group('bson', () {
    _testObject(
        {},
        [5, 0, 0, 0, 0]);
    _testObject(
        {'a': null},
        [8, 0, 0, 0, 10, 97, 0, 0]);
    _testObject(
        {'a': false},
        [9, 0, 0, 0, 8, 97, 0, 0, 0]);
    _testObject(
        {'a': true},
        [9, 0, 0, 0, 8, 97, 0, 1, 0]);
    _testObject(
        {'a': ''},
        [13, 0, 0, 0, 2, 97, 0, 1, 0, 0, 0, 0, 0],
        name: 'String empty');
    _testObject(
        {'a': 'abc'},
        [16, 0, 0, 0, 2, 97, 0, 4, 0, 0, 0, 97, 98, 99, 0, 0],
        name: 'String abc');
    _testObject(
        {'a': '©®ȼɤ₩'},
        [24, 0, 0, 0, 2, 97, 0, 12, 0, 0, 0, 194, 169, 194, 174, 200, 188, 201, 164, 226, 130, 169, 0, 0],
        name: 'String utf-8');
    _testObject(
        {'a': 0},
        [12, 0, 0, 0, 16, 97, 0, 0, 0, 0, 0, 0],
        name: 'int zero');
    _testObject(
        {'a': -0x80000000},
        [12, 0, 0, 0, 16, 97, 0, 0, 0, 0, 128, 0],
        name: 'int 32 min');
    _testObject(
        {'a': 0x7fffffff},
        [12, 0, 0, 0, 16, 97, 0, 255, 255, 255, 127, 0],
        name: 'int 32 max');
    _testObject(
        {'a': -0x8000000000000000},
        [16, 0, 0, 0, 18, 97, 0, 0, 0, 0, 0, 0, 0, 0, 128, 0],
        name: 'int 64 min');
    _testObject(
        {'a': 0x7fffffffffffffff},
        [16, 0, 0, 0, 18, 97, 0, 255, 255, 255, 255, 255, 255, 255, 127, 0],
        name: 'int 64 max');
    _testObject(
        {'a': 0xFFFFFFFFFFFFFFFF},
        [16, 0, 0, 0, 17, 97, 0, 255, 255, 255, 255, 255, 255, 255, 255, 0],
        name: 'uint 64 max');
    _testObject(
        {'a': 0.0},
        [16, 0, 0, 0, 1, 97, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        name: 'double zero');
    _testObject(
        {'a': 45.78},
        [16, 0, 0, 0, 1, 97, 0, 164, 112, 61, 10, 215, 227, 70, 64, 0],
        name: 'double 45.78');
    _testObject(
        {'a': -45.78},
        [16, 0, 0, 0, 1, 97, 0, 164, 112, 61, 10, 215, 227, 70, 192, 0],
        name: 'double -45.78');
    _testObject(
        {'a': double.INFINITY},
        [16, 0, 0, 0, 1, 97, 0, 0, 0, 0, 0, 0, 0, 240, 127, 0],
        name: 'double inf');
    _testObject(
        {'a': double.NEGATIVE_INFINITY},
        [16, 0, 0, 0, 1, 97, 0, 0, 0, 0, 0, 0, 0, 240, 255, 0],
        name: 'double neg inf');
    _testObject(
        {'a': double.NAN},
        null, // Cannot assume format
        name: 'double nan',
        matcher: const PropertyMatcher('a', isNaN));
    _testObject(
        {'a': new DateTime(0)},
        [16, 0, 0, 0, 9, 97, 0, 0, 160, 251, 144, 117, 199, 255, 255, 0],
        name: 'date 0');
    _testObject(
        {'a': new DateTime(2014)},
        [16, 0, 0, 0, 9, 97, 0, 0, 132, 25, 75, 67, 1, 0, 0, 0],
        name: 'date 2014');
    _testObject(
        {'a': new DateTime(-2014)},
        [16, 0, 0, 0, 9, 97, 0, 0, 24, 4, 220, 167, 141, 255, 255, 0],
        name: 'date -2014');
    _testObject(
        {'a': new DateTime.now()},
        null,
        name: 'date now');
    _testObject(
        {'a': new Duration()},
        null,
        matcher: equals({'a': 0}),
        name: 'duration 0');
    _testObject(
        {'a': new Duration(microseconds: 10000000)},
        null,
        matcher: equals({'a': 10000000}),
        name: 'duration +');
    _testObject(
        {'a': new Duration(microseconds: -10000000)},
        null,
        matcher: equals({'a': -10000000}),
        name: 'duration -');
    _testObject(
        {'a': new Uint8List.fromList([0,1,2,3,4,5,6,7,8,9])},
        null,
        name: 'typed_data');
    _testObject(
        {'a': const SchemaId(const [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12])},
        null,
        name: 'SchemaId');
    _testObject(
        {'a': new RegExp(r'\b')},
        null,
        name: 'regexp 1',
        matcher: const PropertyMatcher('a',
            const IsRegExp(r'\b',
                multiLine: false,
                caseSensitive: true)));
    _testObject(
        {'a': new RegExp(r'\b', multiLine: true)},
        null,
        name: 'regexp 2',
        matcher: const PropertyMatcher('a',
            const IsRegExp(r'\b',
                multiLine: true,
                caseSensitive: true)));
    _testObject(
        {'a': new RegExp(r'\b', caseSensitive: false)},
        null,
        name: 'regexp 3',
        matcher: const PropertyMatcher('a',
            const IsRegExp(r'\b',
                multiLine: false,
                caseSensitive: false)));
    _testObject(
        {'a': new RegExp(r'\b', caseSensitive: false, multiLine: true)},
        null,
        name: 'regexp 4',
        matcher: const PropertyMatcher('a',
            const IsRegExp(r'\b',
                multiLine: true,
                caseSensitive: false)));
    _testObject(
        {'a': []},
        [13, 0, 0, 0, 4, 97, 0, 5, 0, 0, 0, 0, 0],
        name: 'list empty');
    _testObject(
        {'a': [null, true, [1, 2, 3]]},
        null,
        name: 'list complex');
    _testObject(
        {'a': {}},
        [13, 0, 0, 0, 3, 97, 0, 5, 0, 0, 0, 0, 0],
        name: 'map empty');
    _testObject(
        {'a': OBJ_RESPONSE},
        null,
        name: 'map complex');
  });
}

void _testObject(Map object, List<int> bytes, {String name, Matcher matcher}) {
  test(name != null ? name : object.toString(), () {
    final resultBytes = bson.encode(object);
    if (bytes != null) {
      expect(resultBytes, equals(bytes));
    }
    final resultObject = bson.decode(resultBytes);
    expect(resultObject, matcher != null ? matcher : equals(object));
  });
}

const Matcher isNaN = const IsNaN();

class IsNaN extends Matcher {
  const IsNaN();
  bool matches(obj, Map matchState) => obj is num && obj.isNaN;
  Description describe(Description description) => description.add('is NaN');
}

class PropertyMatcher extends Matcher {
  final String  property;
  final Matcher matcher;
  const PropertyMatcher(this.property, this.matcher);
  bool matches(obj, Map matchState)
      => obj is Map
            && obj.containsKey(property)
            && matcher.matches(obj[property], matchState);
  Description describe(Description description)
      => description.add('Property "$property": ${matcher.describe(description)}');
}

class IsRegExp extends Matcher {
  final String  pattern;
  final bool    multiLine;
  final bool    caseSensitive;
  const IsRegExp(this.pattern, {this.multiLine: false, this.caseSensitive: true});
  bool matches(obj, Map matchState)
      => obj is RegExp
            && obj.pattern == pattern
            && obj.isMultiLine == multiLine
            && obj.isCaseSensitive == caseSensitive;
  Description describe(Description description) => description.add('is RegExp');
}

const OBJ_BOOK = const {
  'id': 0,
  'title': 'An Awesome Book Title',
  'releaseDate': '2010-12-25',
  'author': const {'id': 0, 'name': 'Smith'},
  'price': const {'amount': 45.67, 'currency': '€'}
};

const OBJ_USER = const {
  'id': 0,
  'age': 33,
  'name': 'Smith',
  'email': 'smith@smith.com',
  'address': const {'street':'Aqui 56, Ali','code':'2967-012','city':'Acolá','country':'PT'},
  'books': const [OBJ_BOOK, OBJ_BOOK, OBJ_BOOK]
};

const OBJ_RESPONSE = const {
  'success': 1,
  'result': const [OBJ_USER, OBJ_USER, OBJ_USER],
  'error': const {'code':'http.bind.unexpectedClose','argument':'Internal Error'}
};
