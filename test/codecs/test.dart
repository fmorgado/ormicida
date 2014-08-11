library test.ormicida.codecs;

import 'package:unittest/unittest.dart';
import 'package:unittest/vm_config.dart';
import 'test_bson.dart' as bson;
import 'test_json.dart' as json;
import 'test_pixm.dart' as pixm;

void main() {
  useVMConfiguration();
  runTests();
}

void runTests() {
  group('orm', () {
    bson.runTests();
    json.runTests();
    pixm.runTests();
  });
}
