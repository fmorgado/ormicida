library test.ormicida.bytes.hex;

import 'package:unittest/unittest.dart';
import 'package:unittest/vm_config.dart';
import 'package:ormicida/bytes/base16.dart';

void main() {
  useVMConfiguration();
  runTests();
}

void runTests() {
  group('Base16', () {
    group('encode', () {
      test('empty', () => expect(Base16.encodeToString([]), equals('')));
      test('[0]', () => expect(Base16.encodeToString([0]), equals('00')));
      test('bytes 1',
          () => expect(Base16.encodeToString([1, 2, 3, 4, 5, 6, 7, 8, 9, 0]),
          equals('01020304050607080900')));
      test('bytes 2',
          () => expect(Base16.encodeToString([145, 94, 200, 45]),
          equals('915EC82D')));
    });
    group('decode', () {
      test('empty', () => expect(Base16.decodeString(''), equals([])));
      test('odd 1', () => expect(Base16.decodeString('0'), equals([0])));
      test('odd 2',
          () => expect(Base16.decodeString('095EC82D'),
          equals([9, 94, 200, 45])));
      test('00', () => expect(Base16.decodeString('00'), equals([0])));
      test('bytes 1',
          () => expect(Base16.decodeString('01020304050607080900'),
          equals([1, 2, 3, 4, 5, 6, 7, 8, 9, 0])));
      test('bytes 2',
          () => expect(Base16.decodeString('915EC82D'),
          equals([145, 94, 200, 45])));
    });
  });
}
