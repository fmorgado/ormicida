library test.ormicida.bytes;

import 'package:unittest/unittest.dart';
import 'package:unittest/vm_config.dart';
import 'bytes/test.dart' as bytes;
import 'codecs/test.dart' as codecs;
import 'orm/test.dart' as orm;

void main() {
  useVMConfiguration();
  runTests();
}

void runTests() {
  group('ormicida', () {
    bytes.runTests();
    codecs.runTests();
    orm.runTests();
  });
}
