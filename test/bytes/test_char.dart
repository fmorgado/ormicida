library test.ormicida.bytes.char;

import 'package:unittest/unittest.dart';
import 'package:unittest/vm_config.dart';
import 'package:ormicida/bytes/char.dart';

void main() {
  useVMConfiguration();
  runTests();
}

void runTests() {
  group('Char', () {
    group('isWhite', () {
      test('SP', () => expect(Char.isWhite(Char.SPACE), equals(true)));
      test('CR', () => expect(Char.isWhite(Char.CARRIAGE_RETURN), equals(true)));
      test('NL', () => expect(Char.isWhite(Char.NEWLINE), equals(true)));
      test('TAB', () => expect(Char.isWhite(Char.TAB), equals(true)));
      test('Other 1', () => expect(Char.isWhite(Char.UNDERSCORE), equals(false)));
      test('Other 2', () => expect(Char.isWhite(Char.PLUS), equals(false)));
    });
    group('isAlpha', () {
      test('a', () => expect(Char.isAlpha(Char.CHAR_a), equals(true)));
      test('z', () => expect(Char.isAlpha(Char.CHAR_z), equals(true)));
      test('A', () => expect(Char.isAlpha(Char.CHAR_A), equals(true)));
      test('Z', () => expect(Char.isAlpha(Char.CHAR_Z), equals(true)));
      test('Other 1', () => expect(Char.isAlpha(Char.CHAR_0), equals(false)));
      test('Other 2', () => expect(Char.isAlpha(Char.TAB), equals(false)));
    });
    group('isDigit', () {
      test('0', () => expect(Char.isDigit(Char.CHAR_0), equals(true)));
      test('9', () => expect(Char.isDigit(Char.CHAR_9), equals(true)));
      test('Other 1', () => expect(Char.isDigit(Char.CHAR_A), equals(false)));
      test('Other 2', () => expect(Char.isDigit(Char.TAB), equals(false)));
    });
    group('isAlphaOrDigit', () {
      test('0', () => expect(Char.isAlphaOrDigit(Char.CHAR_0), equals(true)));
      test('9', () => expect(Char.isAlphaOrDigit(Char.CHAR_9), equals(true)));
      test('a', () => expect(Char.isAlphaOrDigit(Char.CHAR_a), equals(true)));
      test('z', () => expect(Char.isAlphaOrDigit(Char.CHAR_z), equals(true)));
      test('A', () => expect(Char.isAlphaOrDigit(Char.CHAR_A), equals(true)));
      test('Z', () => expect(Char.isAlphaOrDigit(Char.CHAR_Z), equals(true)));
      test('Other 1', () => expect(Char.isAlphaOrDigit(Char.PLUS), equals(false)));
      test('Other 2', () => expect(Char.isAlphaOrDigit(Char.TAB), equals(false)));
    });
    group('isHex', () {
      test('0', () => expect(Char.isHex(Char.CHAR_0), equals(true)));
      test('9', () => expect(Char.isHex(Char.CHAR_9), equals(true)));
      test('a', () => expect(Char.isHex(Char.CHAR_a), equals(true)));
      test('f', () => expect(Char.isHex(Char.CHAR_f), equals(true)));
      test('A', () => expect(Char.isHex(Char.CHAR_A), equals(true)));
      test('F', () => expect(Char.isHex(Char.CHAR_F), equals(true)));
      test('z', () => expect(Char.isHex(Char.CHAR_z), equals(false)));
      test('Z', () => expect(Char.isHex(Char.CHAR_Z), equals(false)));
      test('Other 1', () => expect(Char.isHex(Char.PLUS), equals(false)));
      test('Other 2', () => expect(Char.isHex(Char.TAB), equals(false)));
    });
    group('toHex', () {
      test('0', () => expect(Char.toHex(0), equals(Char.CHAR_0)));
      test('9', () => expect(Char.toHex(9), equals(Char.CHAR_9)));
      test('a', () => expect(Char.toHex(10), equals(Char.CHAR_A)));
      test('f', () => expect(Char.toHex(15), equals(Char.CHAR_F)));
    });
    group('fromHex', () {
      test('0', () => expect(Char.fromHex(Char.CHAR_0), equals(0)));
      test('9', () => expect(Char.fromHex(Char.CHAR_9), equals(9)));
      test('a', () => expect(Char.fromHex(Char.CHAR_a), equals(10)));
      test('f', () => expect(Char.fromHex(Char.CHAR_f), equals(15)));
      test('A', () => expect(Char.fromHex(Char.CHAR_A), equals(10)));
      test('F', () => expect(Char.fromHex(Char.CHAR_F), equals(15)));
    });
  });
}
