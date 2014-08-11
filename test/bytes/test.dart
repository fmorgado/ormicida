library test.ormicida.bytes;

import 'package:unittest/unittest.dart';
import 'package:unittest/vm_config.dart';
import 'test_base64.dart' as base64;
import 'test_buffer.dart' as buffer;
import 'test_char.dart' as char;
import 'test_base16.dart' as hex;

void main() {
  useVMConfiguration();
  runTests();
}

void runTests() {
  group('bytes', () {
    buffer.runTests();
    char.runTests();
    base64.runTests();
    hex.runTests();
  });
}
