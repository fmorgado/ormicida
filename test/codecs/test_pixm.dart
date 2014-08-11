library test.ormicida.codecs.pixm;

import 'dart:typed_data';
import 'package:unittest/unittest.dart';
import 'package:unittest/vm_config.dart';
//import 'package:unittest/html_config.dart';
import 'package:ormicida/codecs/pixm.dart';
import 'package:ormicida/codec.dart';

void main() {
  useVMConfiguration();
  //useHtmlConfiguration();
  runTests();
}

void runTests() {
  group('pixm', () {
    
    group('constants', () {
      _testObject(null);
      _testObject(false);
      _testObject(true);
      _testObject(double.NAN, matcher: isNaN);
      _testObject(double.INFINITY);
      _testObject(double.NEGATIVE_INFINITY);
    });
    
    group('ints', () {
      _testObject(0);
      _testObject(1);
      _testObject(-1);
      _testObject(15, name: 'small +max');
      _testObject(-15, name: 'small -max');
      _testObject(16, name: 'medium +min');
      _testObject(-16, name: 'medium -min');
      _testObject(255);
      _testObject(-255);
      _testObject(12345);
      _testObject(-12345);
      _testObject(0xFFFFFFFFFFFFFF, name: 'medium +max');
      _testObject(-0xFFFFFFFFFFFFFF, name: 'medium -max');
      _testObject(0x100000000000000, name: 'long +min');
      _testObject(-0x100000000000000, name: 'long -min');
      _testObject(19028340289347901238479128037490128374901283748901273489012734890,
          name: '+huge');
      _testObject(-19028340289347901238479128037490128374901283748901273489012734890,
          name: '-huge');
    });
    
    group('doubles', () {
      _testObject(0.0);
      _testObject(1.0);
      _testObject(-1.0);
      _testObject(23452345.23452345, name: '+huge');
      _testObject(-23452345.23452345, name: '-huge');
    });
    
    group('strings', () {
      _testObject('', name: 'empty');
      _testObject('abc');
      _testObject('123');
      _testObject('abc\bdef\tghi\njkl\rmno', name: 'whites');
      _testObject('Ã¡Ã Ã¤Ã£ÂªÂºÃ©Ã¨Ã«', name: 'utf-8 1');
      _testObject('Ã¡Ã Ò¾Ó‚â‚´â„¢â‚³ï»€ï»�', name: 'utf-8 2');
      _testObject('Ã£ÂªÂºÃ©Ã¨Ã«Ã�Ã€Ã„ÃƒÃ§Ã¡Ã Ã¤Ã£ÂªÂºÃ©Ã¨Ã«Ã�Ã€Ã„ÃƒÃ§Ã¡Ã Ã¤Ã£ÂªÂºÃ©Ã¨Ã«Ã�Ã€Ã„ÃƒÃ§Ã¡Ã Ã¤Ã£ÂªÂºÃ©Ã¨Ã«Ã�Ã€Ã„Ãƒ', name: 'utf-8 3');
    });
    
    group('bytes', () {
      final empty = new Uint8List(0);
      final tiny = new Uint8List.fromList([0,1,2,3,4,5,6,7,8,9]);
      final huge = new Uint8List.fromList([0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9]);
      
      _testObject(empty, name: 'empty');
      _testObject(tiny, name: 'short');
      _testObject(huge, name: 'long');
    });
    
    group('lists', () {
      final empty = [];
      final short = [1,2,3];
      final long = [1,2,3,4,5,6,7,8,9,0];
      final nested = [[1,2,3,[4,5,6,[[7,8,9],10,11,12],13],14]];
      
      _testObject(empty, name: 'empty');
      _testObject(short, name: 'short');
      _testObject(long, name: 'long');
      _testObject(nested, name: 'nested');
    });
    
    group('maps', () {
      final empty = {};
      final short = {'a':1,'b':2,'c':3};
      final long = {'a':1,'b':2,'c':3,'d':4,'e':5,'f':6,'g':7,'h':8,'i':9};
      final nested = {'a':1,'b':{'c':{'d':4,'e':{}},'f':{'g':7,'h':8}},'i':9};
      
      _testObject(empty, name: 'empty');
      _testObject(short, name: 'short');
      _testObject(long, name: 'long');
      _testObject(nested, name: 'nested');
    });
    
    group('dates', () {
      _testObject(new DateTime(0), name: 'zero');
      _testObject(new DateTime.now(), name: '+now');
      _testObject(new DateTime.fromMillisecondsSinceEpoch(
          new DateTime.now().millisecondsSinceEpoch), name: '-now');
      _testObject(new DateTime.fromMillisecondsSinceEpoch(8640000000000000), name: '+max');
      _testObject(new DateTime.fromMillisecondsSinceEpoch(-8640000000000000), name: '-max');
    });
    
    group('durations', () {
      _testObject(new Duration(), name: 'zero');
      _testObject(new Duration(seconds: 10), name: '+seconds');
      _testObject(new Duration(seconds: -10), name: '-seconds');
      _testObject(new Duration(hours: 10), name: '+hours');
      _testObject(new Duration(hours: -10), name: '-hours');
      _testObject(new Duration(days: 10), name: '+days');
      _testObject(new Duration(days: -10), name: '-days');
      _testObject(new Duration(days: 0xFFFFFFFFFF), name: '+huge');
      _testObject(new Duration(days: -0xFFFFFFFFFF), name: '-huge');
    });
    
    group('schema_ids', () {
      _testObject(new SchemaId(const [0]), name: 'zero');
      _testObject(new SchemaId(const [243,45,23]), name: 'small');
      _testObject(new SchemaId(const [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]), name: 'huge');
    });
    
    group('reg_exps', () {
      const PATTERN = r'\d';
      _testObject(new RegExp(PATTERN), name: 'test_1',
          matcher: const IsRegExp(PATTERN));
      _testObject(new RegExp(PATTERN, multiLine: true), name: 'test_2',
          matcher: const IsRegExp(PATTERN, multiLine: true));
      _testObject(new RegExp(PATTERN, caseSensitive: false), name: 'test_3',
          matcher: const IsRegExp(PATTERN, caseSensitive: false));
      _testObject(new RegExp(PATTERN, multiLine: true, caseSensitive: false), name: 'test_4',
          matcher: const IsRegExp(PATTERN, multiLine: true, caseSensitive: false));
    });
    
    _testObject(OBJ_RESPONSE, name: 'complex');
  });
}

void _testObject(object, {String name, Matcher matcher}) {
  test(name != null ? name : object.toString(), () {
    expect(pixm.decode(pixm.encode(object)),
        matcher != null ? matcher : equals(object));
  });
}

const Matcher isNaN = const IsNaN();

class IsNaN extends Matcher {
  const IsNaN();
  bool matches(obj, Map matchState) => obj is num && obj.isNaN;
  Description describe(Description description) => description.add('is NaN');
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
  'price': const {'amount': 45.67, 'currency': 'â‚¬'}
};

const OBJ_USER = const {
  'id': 0,
  'age': 33,
  'name': 'Smith',
  'email': 'smith@smith.com',
  'address': const {'street':'Aqui 56, Ali','code':'2967-012','city':'AcolÃ¡','country':'PT'},
  'books': const [OBJ_BOOK, OBJ_BOOK, OBJ_BOOK]
};

const OBJ_RESPONSE = const {
  'success': 1,
  'result': const [OBJ_USER, OBJ_USER, OBJ_USER],
  'error': const {'code':'http.bind.unexpectedClose','argument':'Internal Error'}
};
