library test.ormicida.bytes.buffer;

import 'dart:convert';
import 'package:unittest/unittest.dart';
import 'package:unittest/vm_config.dart';
import 'package:ormicida/bytes/buffer.dart';

import '../_utils.dart';

void main() {
  useVMConfiguration();
  runTests();
}

final _buffer = new Buffer();

void runTests() {
  group('buffer', () {
    group('bytes', () {
      const BYTES = const [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
      
      test('single', () {
        _buffer.clear();
        for (int index = 0; index < BYTES.length; index++) {
          _buffer.addByte(BYTES[index]);
        }
        expect(_buffer.bytes, equals(BYTES));
        expect(_buffer.availableBytes, equals(BYTES.length));
        
        List<int> result = [];
        while (_buffer.availableBytes > 0) {
          result.add(_buffer.getByte());
        }
        expect(_buffer.availableBytes, equals(0));
        expect(result, equals(BYTES));
      });
      
      test('list', () {
        _buffer.clear();
        _buffer.addBytes(BYTES);
        expect(_buffer.bytes, equals(BYTES));
        expect(_buffer.availableBytes, equals(BYTES.length));
        expect(_buffer.getBytes(_buffer.availableBytes), equals(BYTES));
        expect(_buffer.availableBytes, equals(0));
      });
    });

    group('strings', () {
      const UTF8_STRING = 'a€bÖc';
      const ASCII_STRING = 'abcdef123';
      
      test('charCode', () {
        _buffer.clear();
        for (int index = 0; index < UTF8_STRING.length; index++) {
          _buffer.addCharCode(UTF8_STRING.codeUnitAt(index));
        }
        expect(UTF8.decode(_buffer.bytes), equals(UTF8_STRING));
        expect(_buffer.availableBytes, equals(8));
        final stringBuffer = new StringBuffer();
        expect(UTF8.decode(_buffer.bytes), equals(UTF8_STRING));
        while (_buffer.availableBytes > 0) {
          stringBuffer.writeCharCode(_buffer.getCharCode());
        }
        expect(stringBuffer.toString(), equals(UTF8_STRING));
        expect(_buffer.availableBytes, equals(0));
      });
      
      test('ascii', () {
        _buffer.clear();
        _buffer.addAscii(ASCII_STRING);
        expect(UTF8.decode(_buffer.bytes), equals(ASCII_STRING));
        expect(_buffer.availableBytes, equals(ASCII_STRING.length));
        expect(UTF8.decode(_buffer.getBytes(_buffer.availableBytes)), equals(ASCII_STRING));
        expect(_buffer.availableBytes, equals(0));
      });
      
      test('utf-8', () {
        _buffer.clear();
        _buffer.addString(UTF8_STRING);
        expect(UTF8.decode(_buffer.bytes), equals(UTF8_STRING));
        expect(_buffer.availableBytes, equals(8));
        expect(UTF8.decode(_buffer.getBytes(_buffer.availableBytes)), equals(UTF8_STRING));
        expect(_buffer.availableBytes, equals(0));
      });
      
      test('both', () {
        _buffer.clear();
        for (int index = 0; index < UTF8_STRING.length; index++) {
          _buffer.addCharCode(UTF8_STRING.codeUnitAt(index));
        }
        _buffer.addAscii(ASCII_STRING);
        _buffer.addString(UTF8_STRING);
        expect(UTF8.decode(_buffer.bytes), equals('$UTF8_STRING$ASCII_STRING$UTF8_STRING'));
      });
    });
    
    test('floats', () {
      void testFloat32(double value, Matcher matcher) {
        _buffer.clear();
        _buffer.addFloat32(value);
        expect(_buffer.availableBytes, equals(4));
        expect(_buffer.getFloat32(), matcher);
        expect(_buffer.availableBytes, equals(0));
      }
      void testFloat64(double value, Matcher matcher) {
        _buffer.clear();
        _buffer.addFloat64(value);
        expect(_buffer.availableBytes, equals(8));
        expect(_buffer.getFloat64(), matcher);
        expect(_buffer.availableBytes, equals(0));
      }
      void testFloat(double value, {num percentage: 1}) {
        final matcher = new IsDoubleValue(value, percentage: percentage);
        testFloat32(value, matcher);
        testFloat64(value, matcher);
      }
      testFloat(0.0, percentage: 0);
      testFloat(12.34);
      testFloat(-12.34);
      testFloat(double.NAN);
      testFloat(double.INFINITY);
      testFloat(double.NEGATIVE_INFINITY);
    });
    
    test('packed', () {
      _buffer.clear();
      _buffer.addPackedUInt(0);
      expect(_buffer.length, equals(1));
      expect(_buffer.getPackedUInt(), equals(0));
      
      _buffer.clear();
      _buffer.addPackedUInt(127);
      expect(_buffer.length, equals(1));
      expect(_buffer.getPackedUInt(), equals(127));
      
      _buffer.clear();
      _buffer.addPackedUInt(128);
      expect(_buffer.length, equals(2));
      expect(_buffer.getPackedUInt(), equals(128));
      
      _buffer.clear();
      _buffer.addPackedUInt(782364789236478);
      expect(_buffer.length, equals(8));
      expect(_buffer.getPackedUInt(), equals(782364789236478));
    });
  });
}
