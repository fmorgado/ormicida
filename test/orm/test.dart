library test.ormicida.orm;

import 'package:unittest/unittest.dart';
import 'package:unittest/vm_config.dart';
import 'test_schema.dart' as schema;
import 'test_mirror_schema.dart' as mirrorSchema;

void main() {
  useVMConfiguration();
  runTests();
}

void runTests() {
  group('orm', () {
    schema.runTests();
    mirrorSchema.runTests();
  });
}
