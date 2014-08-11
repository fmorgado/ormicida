library test.ormicida.bytes.base64;

import 'package:unittest/unittest.dart';
import 'package:unittest/vm_config.dart';
import 'package:ormicida/bytes/base64.dart';

void main() {
  useVMConfiguration();
  runTests();
}

void runTests() {
  group('base64', () {
    group('encode', () {
      test('empty',
          () => expect(Base64.encodeToString([]),
          equals('')));
      test('length 1',
          () => expect(Base64.encodeToString([0]),
          equals('AA==')));
      test('length 2',
          () => expect(Base64.encodeToString([0, 1]),
          equals('AAE=')));
      test('length 3',
          () => expect(Base64.encodeToString([0, 1, 2]),
          equals('AAEC')));
      test('length 4',
          () => expect(Base64.encodeToString([0, 1, 2, 3]),
          equals('AAECAw==')));
      test('test 1',
          () => expect(Base64.encodeToString([1, 2, 3, 4, 5, 6, 7, 8, 9, 0]),
          equals('AQIDBAUGBwgJAA==')));
      test('test 2',
          () => expect(Base64.encodeToString([145, 94, 200, 45]),
          equals('kV7ILQ==')));
    });
    group('decode', () {
      test('empty',
          () => expect(Base64.decodeString(''),
          equals([])));
      test('length 1',
          () => expect(Base64.decodeString('AA=='),
          equals([0])));
      test('length 2',
          () => expect(Base64.decodeString('AAE='),
          equals([0, 1])));
      test('length 3',
          () => expect(Base64.decodeString('AAEC'),
          equals([0, 1, 2])));
      test('length 4',
          () => expect(Base64.decodeString('AAECAw=='),
          equals([0, 1, 2, 3])));
      test('test 1',
          () => expect(Base64.decodeString('AQIDBAUGBwgJAA=='),
          equals([1, 2, 3, 4, 5, 6, 7, 8, 9, 0])));
      test('test 2',
          () => expect(Base64.decodeString('kV7ILQ=='),
          equals([145, 94, 200, 45])));
    });
  });
}
